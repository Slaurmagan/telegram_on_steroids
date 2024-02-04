class ExampleAction < TelegramOnSteroids::Action
  on_redirect do |action|
    action.send_message text: 'Text'
  end

  on_message do |action|
    action.send_message text: 'Text'
  end

  on_callback_query whitelist: [] do |action|
    action.answer_callback_query
  end
end
