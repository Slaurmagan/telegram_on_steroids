class TelegramOnSteroids::Keyboard::Button
  extend TelegramOnSteroids::Configurable

  def initialize(text:, callback_data:, keyboard:)
    @text = text
    @callback_data = callback_data
    @keyboard = keyboard
  end

  def to_telegram_format
    text = @text.is_a?(Proc) ? keyboard.instance_eval(&@text) : @text
    { text:, callback_data: }
  end

  attr_reader :text, :callback_data, :keyboard
end
