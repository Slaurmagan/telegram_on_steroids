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
      def initialize(buttons: [], paginatable: false)
        @buttons = buttons
        @paginatable = paginatable
      end

      def add_button(button)
        @buttons.push(button)
      end

      attr_reader :buttons
    end

    def initialize(request:, buttons: self.class.buttons)
      @request = request
      @buttons = buttons
    end

    def add_button(button)
      @buttons.push(button)
    end

    def to_telegram_format
      [buttons]
    end

    attr_reader :buttons, :request
  end
end
