# Загрузка анекдотов
#  (134..2021).to_a.each {|j| puts j ; Anecdotes::LoadService.call(j) ; sleep rand(60) }
module Anecdotes
  class LoadTextService < BaseService
    param :text, type: Types::Coercible::String

    def call
      openai_token = Settings.openai.key
      openai_client = OpenAI::Client.new(access_token: openai_token)

      pinecone ||= begin
        Pinecone.configure do |config|
          config.api_key = Settings.pinecone.key
          config.environment = Settings.pinecone.environment
        end

        Pinecone::Client.new
      end
      # TODO: вынести в Settings
      pc_index = pinecone.index('example-index')

      doc = Nokogiri::HTML(text, 'UTF-8')
      anecdotes = doc.css('.q').map do |quote|
        id = quote.css('.vote a').first['href'].scan(/\d+/).first.to_i
        html = quote.css('.quote')[0].children.map(&:text).reject { |c| c.empty? }.join("<br/>\n")

        { id: id, html: html }
      end

      vectors = anecdotes.map do |anekdot|
        begin
          vector = openai_client.embeddings(
            parameters: {
              model: 'text-embedding-ada-002',
              input: anekdot[:html]
            }
          )
          vector['data'][0]['embedding']
        rescue
          # if vector.dig('error', 'message').present?
          puts "#{__FILE__}:#{__LINE__} | sleep"
          sleep(10)
          retry
        end
      end

      meta_vector = anecdotes.map.with_index do |anekdot, j|
        {
          id: anekdot[:id].to_s,
          metadata: {
            key: :anekdot,
            html: anekdot[:html]
          },
          values: vectors[j]
        }
      end

      # заполняем БД
      pc_index.upsert(vectors: [meta_vector], namespace: 'anekdot')
    end
  end
end
