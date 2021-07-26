class Kredis::Types::Proxy
  require_relative "proxy/failsafe"
  include Failsafe

  attr_accessor :redis, :key

  def initialize(redis, key, **options)
    @redis, @key = redis, key
    options.each { |key, value| send("#{key}=", value) }
  end

  def multi(...)
    redis.multi(...)
  end

  def method_missing(method, *args, **kwargs)
    failsafe do
      Kredis.instrument :proxy, **log_message(method, *args, **kwargs)
      redis.public_send method, key, *args, **kwargs
    end
  end

  private
    def log_message(method, *args, **kwargs)
      args      = args.flatten.reject(&:blank?).presence
      kwargs    = kwargs.reject { |_k, v| v.blank? }.presence
      type_name = self.class.name.split("::").last

      { type: type_name,
        message: "#{method.upcase} #{key} #{args&.inspect} #{kwargs&.inspect}".chomp }
    end
end
