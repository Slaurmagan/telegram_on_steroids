unless defined?(Rails)
  require "logger"
end

module TelegramOnSteroids
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield(config)
      config.verify!

      @__after_configuration.call(config) if @__after_configuration
    end

    def __after_configuration(&block)
      @__after_configuration = block
    end
  end

  class Configuration
    attr_accessor :session_store, :logger, :client, :start_action, :webhook_url, :api_token,
                  :webhook_params, :commands

    REQUIRED_PARAMS = %i(start_action api_token)

    def initialize
      @client = TelegramOnSteroids::Client
      @webhook_params = {}

      if defined?(Rails)
        @session_store = Rails.cache
        @logger = Rails.logger
      else
        @session_store = InMemoryStore
        @logger = Logger.new(STDOUT)
      end
    end

    def verify!
      blank_params = REQUIRED_PARAMS.select { |p| send(p).nil? }

      if blank_params.any?
        raise StandardError, blank_params
      end
    end
  end
end
