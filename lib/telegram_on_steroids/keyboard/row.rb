class TelegramOnSteroids::Keyboard::Row
  def initialize(keyboard:)
    @buttons = []
    @keyboard = keyboard
  end

  def button(**button)
    buttons.push(TelegramOnSteroids::Keyboard::Button.new(**button, keyboard:).to_telegram_format)
  end

  attr_reader :buttons, :keyboard
end
