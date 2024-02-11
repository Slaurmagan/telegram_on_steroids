require_relative './telegram_on_steroids/configurable'
require_relative './telegram_on_steroids/keyboard'
require_relative './telegram_on_steroids/keyboard/inline_keyboard'
require_relative './telegram_on_steroids/keyboard/paginatable'
require_relative './telegram_on_steroids/keyboard/button'
require_relative './telegram_on_steroids/keyboard/row'
require_relative './telegram_on_steroids/action'
require_relative './telegram_on_steroids/client'
require_relative './telegram_on_steroids/params'
require_relative './telegram_on_steroids/updates'
require_relative './telegram_on_steroids/configuration'
require_relative './telegram_on_steroids/process'
require_relative './telegram_on_steroids/session'
require_relative './telegram_on_steroids/version'
require_relative './telegram_on_steroids/in_memory_store'
require_relative './telegram_on_steroids/redis_store'

module TelegramOnSteroids
  UPDATE_TYPES = %w[message edited_message channel_post edited_channel_post message_reaction message_reaction_count inline_query chosen_inline_request callback_query shipping_query poll poll_answer my_chat_member chat_member chat_join_request chat_boost removed_chat_boost]

  def self.process(params)
    Process.new(params).process
  end

  def self.updates(offset: nil, limit: nil, timeout: 60, allowed_updates: nil)
    params = {}
    params[:offset] = offset if offset
    params[:limit] = limit if limit
    params[:timeout] = timeout if timeout
    params[:allowed_updates] = allowed_updates if allowed_updates

    (@updates = Updates.new(params)).enum
  end

  def self.stop_updates
    @updates && @updates.stop = true
  end
end
