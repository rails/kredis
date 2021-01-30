class Kredis::Proxy
  def initialize(redis, key)
    @redis, @key = redis, key
  end

  def multi(...)
    @redis.multi(...)
  end

  def method_missing(method, *args, **kwargs)
    @redis.public_send method, @key, *args, **kwargs
  end
end
