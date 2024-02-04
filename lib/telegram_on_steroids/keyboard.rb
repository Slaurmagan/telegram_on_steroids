module TelegramOnSteroids
  class Keyboard
    class << self
      def keyboard
        @keyboard ||= Keyboard.new
      end

      def configure
        yield keyboard
      end

      private

      def method_missing(symbol, *args)
        raise NotImplementedError unless keyboard.respond_to?(symbol)

        keyboard.send(symbol, *args)
      end
    end

    def initialize(buttons: [], paginatable: false)
      @buttons = buttons
      @paginatable = paginatable
    end

    def add_button(button)
      @buttons.push(button)
    end

    def to_telegram_format
      [buttons]
    end

    attr_accessor :paginatable
    attr_reader :buttons
  end
end
