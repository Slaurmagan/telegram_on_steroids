module TelegramOnSteroids
  class Keyboard
    class << self
      def configuration
        @keyboard ||= Configuration.new
      end

      def configure
        yield configuration
      end

      private

      def method_missing(symbol, *args)
        raise NotImplementedError unless configuration.respond_to?(symbol)

        configuration.send(symbol, *args)
      end
    end

    class Configuration
      def initialize
        @buttons = []
      end

      def button(button)
        buttons.push([button])
      end

      def row
        row = Row.new
        yield row
        buttons.push(row.buttons)
      end

      attr_reader :buttons
      attr_accessor :text, :per_page
    end

    class Row
      def initialize
        @buttons = []
      end

      def button(button)
        buttons.push(button)
      end

      attr_reader :buttons
    end

    def initialize(request:, configuration: self.class.configuration)
      @request = request
      @configuration = configuration
      @buttons = configuration.buttons
    end

    def add_button(button)
      @buttons.push(button)
    end

    def to_telegram_format
      buttons
    end

    def text
      instance_eval(&configuration.text)
    end

    attr_reader :buttons, :request, :configuration
  end
end
