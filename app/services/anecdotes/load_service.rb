module Anecdotes
  class LoadService < BaseService
    param :page_number, type: Types::Coercible::Integer

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

      url = "http://bashorg.org/page/#{page_number}/"
      # url = 'http://bashorg.org/page/6/'
      html = URI.open(url)
      doc = Nokogiri::HTML(html, "UTF-8")
      anekdots = doc.css('.q').map do |quote|
        id = quote.css('.vote a').first['href'].scan(/\d+/).first.to_i
        html = quote.css('.quote')[0].children.map(&:text).reject{|c| c.empty?}.join("<br/>\n")

        { id: id, html: html }
      end

      vectors = anekdots.map do |anekdot|
        vector = openai_client.embeddings(
          parameters: {
            model: 'text-embedding-ada-002',
            input: anekdot[:html]
          }
        )
        vector['data'][0]['embedding']
      end

      meta_vector = anekdots.map.with_index do |anekdot, j|
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
