class TelegramOnSteroids::Session
  def initialize(params)
    @session_id = [params.user_id, params.chat_id].join('.')
    @store = TelegramOnSteroids.config.session_store
    @session = if serialized_session = @store.read(@session_id)
                 Oj.load(serialized_session)
               else
                 {}
               end
  end

  def read(key)
    @session[key]
  end

  def write(key, value)
    @session[key] = value
  end

  def delete(key)
    @session.delete(key)
  end

  def clear
    @session.clear
  end

  def dump
    @session_id && @store.write(@session_id, Oj.dump(@session))
  end

  # this is a user space to store some session data separately from the gem session
  def user_session
    @session_id ?
      @session[:user_session] ||= {} :
      NullSession.new
  end

  # this is a temporary per-action store
  def flash
    @session_id ?
      @session[:flash] ||= {} :
      NullSession.new
  end

  def reset_flash
    flash.clear
  end

  class NullSession < Hash
  end
end
