require 'forwardable'

module TelegramOnSteroids
  class Action
    extend Forwardable

    def initialize(request, client, session)
      @client = client
      @session = session
      @action = self.class.action
      @request = request
      set_session!
      set_client!
      set_request!
    end

    def set_session!
      action.session = session
    end

    def set_client!
      action.client = client
    end

    def set_request!
      action.request = request
    end

    attr_reader :client, :session, :action, :request

    def_delegators :@request, :params

    def respond_to_missing?(name, include_private = false)
      @action.respond_to?(name, include_private)
    end

    def method_missing(method, *args, &block)
      @action.send(method, *args, &block)
    end

    class << self
      def action
        @action ||= Base.new
      end

      def method_missing(symbol, *args, &block)
        raise NotImplementedError unless action.respond_to?(symbol)

        action.send(symbol, *args, &block)
      end
    end

    class Base
      def initialize
        @filters = {}
      end

      def send_message(params)
        client.send_message params
      end

      def respond_with_keyboard(text: '', keyboard: current_keyboard)
        keyboard_instance = keyboard.new(request:)
        inline_keyboard = keyboard_instance.to_telegram_format
        message_id = request.params.to_h.dig('callback_query', 'message', 'message_id')
        text = keyboard_instance.text

        if message_id
          client.edit_message_text message_id:, text:, reply_markup: { inline_keyboard: }
          session.write(:keyboard, keyboard.name)
        else
          client.send_message text:, reply_markup: { inline_keyboard: }
          session.write(:keyboard, keyboard.name)
        end
      end

      def answer_callback_query(**params)
        client.answer_callback_query callback_query_id: request.params.to_h.dig('callback_query', 'id'), **params
      end

      def on_redirect(&block)
        @on_redirect = block
      end

      def on_message(&block)
        @on_message = block
      end

      def on_callback(&block)
        @on_callback = block
      end

      def __run_on_redirect
        @on_redirect.call(request, self) if @on_redirect
      end

      def __run_on_message
        @on_message.call(request, self) if @on_message
      end

      def __run_on_callback
        return respond_with_keyboard if pagination_callback? && current_keyboard

        @on_callback.call(request, self) if @on_callback
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
end
