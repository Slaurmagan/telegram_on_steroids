class TelegramOnSteroids::Process
  attr_reader :params, :client, :session

  def initialize(raw_params)
    @params  = TelegramOnSteroids::Params.new(raw_params)
    @session = TelegramOnSteroids::Session.new(@params)
    chat_id = @params.chat_id
    @client = TelegramOnSteroids.config.client.new(chat_id)
    @logger = TelegramOnSteroids.config.logger

    if TelegramOnSteroids.config.commands.keys.include?(params.message_text)
      set_current_action(TelegramOnSteroids.config.commands[params.message_text])
    end
  end

  def log_request
    @logger.info "[TelegramOnSteroids] Processing by #{current_action.class.name}##{current_step}"
    @logger.info "[TelegramOnSteroids] Params: #{params.to_h}"
  end

  def process
    log_request

    if params.callback?
      current_action.__run_on_callback if current_action.respond_to?(:__run_on_callback)
    else
      session.write(:current_page, 1)
      current_action.__run_on_message
    end

    if current_action.redirect_to
      do_redirect
    end

    @session.dump

    @client.inline_request
  end

  private

  def current_action
    @current_action ||= begin
                          action_class = if action = session.read(:current_action)
                                           Object.const_get(action)
                                         else
                                           TelegramOnSteroids.config.start_action
                                         end

                          action_class.new(request: self, client: @client, session:)
                        end
  end

  def set_current_action(action_class)
    session.write(:current_action, action_class.to_s)
    set_current_step(nil)
    session.reset_flash

    @current_action = action_class.new(request: self, client: @client, session:)
  end

  def current_step
    @session.read(:current_step) || :initial
  end

  def set_current_step(step)
    @session.write(:current_step, step)
  end

  def do_redirect
    action_or_step = @redirect_to
    session_params = @session_params

    set_current_action(current_action.redirect_to)
    current_action.__run_on_redirect
  end
end
