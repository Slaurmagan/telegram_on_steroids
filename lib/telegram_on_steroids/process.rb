class TelegramOnSteroids::Process
  attr_reader :params, :client, :session

  def initialize(raw_params)
    @params  = TelegramOnSteroids::Params.new(raw_params)
    @session = TelegramOnSteroids::Session.new(@params)
    chat_id = @params.chat_id
    @client = TelegramOnSteroids.config.client.new(chat_id)
    @logger = TelegramOnSteroids.config.logger

    if @params.start?
      set_current_action(TelegramOnSteroids.config.start_action)
    end
  end

  def log_request
    @logger.info "[TelegramOnSteroids] Processing by #{current_action.class.name}##{current_step}"
    @logger.info "[TelegramOnSteroids] Params: #{params.to_h}"
  end

  def process
    # run the shared step
    log_request

    if params.callback?
      current_action.__run_on_callback
    else
      current_action.__run_on_message
    end

    while @redirect_to
      do_redirect
    end

    @session.dump

    @client.inline_request
  end

  def redirect_to(action_or_step, session_params = nil)
    # raise TelegramWorkflow::Errors::DoubleRedirect if @redirect_to
    # raise TelegramWorkflow::Errors::SharedRedirect if action_or_step == :shared
    # raise TelegramWorkflow::Errors::StartRedirect  if action_or_step == TelegramWorkflow.config.start_action

    @redirect_to = action_or_step
    @session_params = session_params
  end

  private

  def current_action
    @current_action ||= begin
                          action_class = if action = session.read(:current_action)
                                           Object.const_get(action)
                                         else
                                           TelegramOnSteroids.config.start_action
                                         end

                          action_class.new(@client, session)
                        end
  end

  def set_current_action(action_class)
    session.write(:current_action, action_class.to_s)
    set_current_step(nil)
    session.reset_flash

    @current_action = action_class.new(@client, session)
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
    @redirect_to = @session_params = nil

    # reset on_message and on_redirect callbacks
    current_action.__reset_callbacks

    if action_or_step.is_a?(Class)
      set_current_action(action_or_step)
    else
      set_current_step(action_or_step)
    end

    if session_params
      session.flash.merge!(session_params)
    end

    current_action.public_send(current_step) # setup callbacks
    current_action.__run_on_redirect # run a callback
  end
end
