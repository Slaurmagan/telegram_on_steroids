class TelegramOnSteroids::Updates
  attr_writer :stop

  def initialize(params)
    @params = params
  end

  def enum
    Enumerator.new do |y|
      loop do
        break if @stop

        updates = TelegramOnSteroids::Client.new.get_updates(@params)["result"]
        updates.each do |update|
          y << update
        end

        if updates.any?
          @params.merge! offset: updates.last["update_id"] + 1
        end
      end
    end
  end
end
