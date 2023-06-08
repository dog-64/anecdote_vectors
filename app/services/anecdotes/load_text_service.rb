# Загрузка анекдотов
#  (134..2021).to_a.each {|j| puts j ; Anecdotes::LoadService.call(j) ; sleep rand(60) }
module Anecdotes
  class LoadTextService < BaseService
    param :text, type: Types::Coercible::String

    def call
      pinecone_index.upsert(vectors: [meta_vector], namespace: 'anecdote')
    end

    private

    def meta_vector
      meta_vector = anecdotes.map.with_index do |anecdote, j|
        {
          id: anecdote[:id].to_s,
          metadata: {
            key: :anecdote,
            html: anecdote[:html]
          },
          values: vectors[j]
        }
      end
    end

    def vectors
      anecdotes.map do |anecdote|
        next if anecdote.blank?

        begin
          puts "#{__FILE__}:#{__LINE__} | anecdote=#{anecdote.inspect}"
          vector = openai_client.embeddings(
            parameters: {
              model: 'text-embedding-ada-002',
              input: anecdote[:html][..10_000] # This model's maximum context length is 8191 tokens, however you requested 20462 tokens
            }
          )
          vector['data'][0]['embedding']
        rescue
          puts "#{__FILE__}:#{__LINE__} | sleep"
          sleep(5)
          retry
        end
      end
    end

    def openai_client
      openai_token = Settings.openai.key
      OpenAI::Client.new(access_token: openai_token)
    end

    def anecdotes
      doc = Nokogiri::HTML(text, 'UTF-8')
      doc.css('.q').map do |quote|
        next if quote.css('.quote').blank?

        id = quote.css('.vote a').first['href'].scan(/\d+/).first.to_i
        html = quote.css('.quote')[0].children.map(&:text).reject { |c| c.empty? }.join("<br/>\n")

        { id: id, html: html }
      end.compact
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
  end
end
