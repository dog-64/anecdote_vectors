module Anecdotes
  class SearchService < BaseService
    param :search, type: Types::Coercible::String

    RESULTS_LIMIT = 3

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

      q_vector = openai_client.embeddings(
        parameters: {
          model: 'text-embedding-ada-002',
          input: search
          # оцени - поняла - что пес это собака, что саппорт - это поддержка
          # 1> С собакой удаленим (фото спящей на диване собаки и ноутбука)2> ты её оставь на поддержке, а сам спать1> хороший план, думаю спарвится2> научи гавкать в трубку, этого достаточно в 90% случаев
          # input: 'про пса и саппорт'
          # input: 'про поддержку по телефону'
          # input: 'про сбереженья'
          # input: 'про напитки'
          # input: 'как устроены вычислительные машины'
          # input: 'рыбные отравления'
        }
      )
      pc_index.query(
        vector: q_vector['data'][0]['embedding'],
        top_k: RESULTS_LIMIT,
        include_values: false,
        include_metadata: true,
        namespace: 'anekdot'
      ).parsed_response['matches']
    end
  end
end
