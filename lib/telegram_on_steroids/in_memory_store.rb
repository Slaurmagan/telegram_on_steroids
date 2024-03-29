class TelegramOnSteroids::InMemoryStore
  def initialize
    @store = {}
  end

  def read(key)
    @store[key]
  end

  def write(key, value)
    @store[key] = value
  end
end
