class Kredis::Types::Proxy
  def initialize(redis, key)
    @redis, @key = redis, key
  end

  def multi(...)
    @redis.multi(...)
  end

  def method_missing(method, *args, **kwargs)
    Kredis.logger&.debug "[Kredis] #{method} #{@key} #{args.inspect if args.compact_blank.any?} #{kwargs.inspect if kwargs.compact_blank.any?}".chomp
    @redis.public_send method, @key, *args, **kwargs
  end
end
