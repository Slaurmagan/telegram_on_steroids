class TelegramOnSteroids::RedisStore
  def initialize
    @client = Redis.new(url: ENV['REDIS_URL'])
  end

  def read(key)
    @client.get(key)
  end

  def write(key, value)
    @client.set(key, value)
  end
end
