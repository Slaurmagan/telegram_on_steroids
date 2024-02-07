require 'forwardable'

module TelegramOnSteroids
  class Action
    extend Forwardable

    attr_reader :client, :session, :action, :request

    ALLOWED_CALLBACKS = %w[callback message redirect]

    class << self
      def on(name, &block)
        raise StandardError, "#{name} not allowed callback" unless ALLOWED_CALLBACKS.include?(name.to_s)

        define_method("on_#{name.to_s}") do
          instance_variable_set('@on_callback', block)
        end

        define_method("__run_on_#{name.to_s}") do
          return respond_with_keyboard if name.to_s == 'callback' && pagination_callback? && current_keyboard

          instance_eval(&block)
        end
      end
    end

    def_delegators :@request, :params
    def_delegators :@client, :send_message

    def initialize(request:, client:, session:)
      @request = request
      @client = client
      @session = session
    end

    attr_reader :request, :client, :session

    def respond_with_keyboard(keyboard: current_keyboard)
      keyboard_instance = keyboard.is_a?(Class) ? keyboard.new(request:, action: self) : keyboard
      inline_keyboard = keyboard_instance.to_telegram_format
      message_id = request.params.to_h.dig('callback_query', 'message', 'message_id')
      text = keyboard_instance.text
      session.write(:current_page, 1) unless keyboard == current_keyboard

      if message_id
        client.edit_message_text message_id:, text:, reply_markup: { inline_keyboard: }
      else
        client.send_message text:, reply_markup: { inline_keyboard: }
      end
      session.write(:keyboard, keyboard.is_a?(Class) ? keyboard.name : keyboard.class.name)
    end

    def answer_callback_query(**params)
      client.answer_callback_query callback_query_id: request.params.to_h.dig('callback_query', 'id'), **params
    end

    def pagination_callback?
      request.params.callback_data =~ /page/
    end

    def current_keyboard
      return unless session.read(:keyboard)

      Object.const_get(session.read(:keyboard))
    end

    def redirect_to=(klass)
      @redirect_to = klass
    end

    attr_accessor :request, :client, :session
    attr_reader :redirect_to
  end
end
