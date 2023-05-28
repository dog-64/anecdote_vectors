class BaseService
  extend Dry::Initializer
  extend Dry::Monads[:result, :try, :do]
  include Dry::Monads[:result, :try, :do]

  def call
    raise NotImplementedError
  end

  class << self
    # Instantiates and calls the service at once
    def call(*args, &block)
      new(*args).call(&block)
    end

    # Accepts both symbolized and stringified attributes
    # def new(*args)
    #   binding.pry
    #   args << args.pop.symbolize_keys if args.last.is_a?(Hash)
    #   binding.pry
    #   super(*args)
    # end
  end
end
