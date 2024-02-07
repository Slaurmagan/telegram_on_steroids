module TelegramOnSteroids
  class Keyboard
    extend Configurable

    callable :text

    def initialize(request:, action:)
      @request = request
      @buttons = []
      @action = action
      after_initialize
    end

    def after_initialize; end

    def button(**button)
      @buttons.push([Button.new(**button, keyboard: self).to_telegram_format])
    end

    def row
      row = Row.new(keyboard: self)
      yield row
      buttons.push(row.buttons)
    end

    def to_telegram_format
      buttons
    end

    attr_reader :buttons, :request, :action
  end
end
