module TelegramOnSteroids
  class Action
    def initialize(client, session)
      @client = client
      @session = session
      @action = self.class.action
      set_session!
      set_client!
    end

    def set_session!
      action.session = session
    end

    def set_client!
      action.client = client
    end

    attr_reader :client, :session, :action

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

      def respond_with_keyboard(text: '', keyboard:)
        client.send_message text:, reply_markup: { inline_keyboard: keyboard.to_telegram_format }
      end

      def on(step_name, proc)
        filters[step_name] ||= []
        filters[step_name].push({ type: :on, proc: })
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
        @on_redirect.call(self) if @on_redirect
      end

      def __run_on_message
        @on_message.call(self) if @on_message
      end

      def __run_on_callback
        @on_callback.call(self) if @on_message
      end

      attr_reader :proc

      attr_accessor :client, :session
    end
  end
end
