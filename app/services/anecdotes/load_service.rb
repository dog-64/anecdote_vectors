# Загрузка анекдотов
#  (134..2021).to_a.each {|j| puts j ; Anecdotes::LoadService.call(j) ; sleep rand(60) }
module Anecdotes
  class LoadService < BaseService
    param :page_number, type: Types::Coercible::Integer

    def call
      # заполняем БД
      pinecone_index.upsert(vectors: [meta_vector], namespace: 'anekdot')
    end

    private

    def meta_vector
      anekdots.map.with_index do |anekdot, j|
        {
          id: anekdot[:id].to_s,
          metadata: {
            key: :anekdot,
            html: anekdot[:html]
          },
          values: vectors[j]
        }
      end
    end

    def vectors
      anecdotes.map do |anekdot|
        vector = openai_client.embeddings(
          parameters: {
            model: 'text-embedding-ada-002',
            input: anekdot[:html]
          }
        )
        vector['data'][0]['embedding']
      rescue
        puts "#{__FILE__}:#{__LINE__} | vector=#{vector.inspect}"
        puts "#{__FILE__}:#{__LINE__} | sleep"
        sleep(5)
        retry
      end
    end

    def anecdotes
      url = "http://bashorg.org/page/#{page_number}/"
      html = URI.open(url)
      doc = Nokogiri::HTML(html, "UTF-8")
      doc.css('.q').map do |quote|
        id = quote.css('.vote a').first['href'].scan(/\d+/).first.to_i
        html = quote.css('.quote')[0].children.map(&:text).reject { |c| c.empty? }.join("<br/>\n")

        { id: id, html: html }
      end
    end

    def pinecone_index
      pinecone ||= begin
        Pinecone.configure do |config|
          config.api_key = Settings.pinecone.key
          config.environment = Settings.pinecone.environment
        end

        Pinecone::Client.new
      end
      # TODO: вынести в Settings
      pinecone.index('example-index')
    end

    def openai_client
      openai_token = Settings.openai.key
      OpenAI::Client.new(access_token: openai_token)
    end
  end
end
