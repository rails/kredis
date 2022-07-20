class Kredis::Types::Proxy
  require_relative "proxy/failsafe"
  include Failsafe

  attr_accessor :key

  thread_mattr_accessor :pipeline

  def initialize(redis, key, **options)
    @redis, @key = redis, key
    options.each { |key, value| send("#{key}=", value) }
  end

  def multi(*args, **kwargs, &block)
    return block.call if self.pipeline # return and execute block for nested multi pipeline

    redis.multi(*args, **kwargs) do |pipeline|
      self.pipeline = pipeline
      block.call
    ensure
      self.pipeline = nil
    end
  end

  def method_missing(method, *args, **kwargs)
    Kredis.instrument :proxy, **log_message(method, *args, **kwargs) do
      failsafe do
        redis.public_send method, key, *args, **kwargs
      end
    end
  end

  CALLNX = <<~LUA
    if redis.call("exists", KEYS[1]) == 0 then
      redis.call("%{method}", KEYS[1], unpack(ARGV))
    end
  LUA
  def callnx(method, values)
    safe_method_name = method.to_s.gsub(/[^a-z_]/, '_')
    cmd = format(CALLNX, method: safe_method_name)
    Kredis.instrument :proxy, **log_message(:callnx, *([safe_method_name] + Array(values))) do
      failsafe do
        redis.eval cmd, Array(key), Array(values).flatten
      end
    end
  end

  private
    def redis
      pipeline || @redis
    end

    def log_message(method, *args, **kwargs)
      args      = args.flatten.reject(&:blank?).presence
      kwargs    = kwargs.reject { |_k, v| v.blank? }.presence

      { message: "#{method.upcase} #{key} #{args&.inspect} #{kwargs&.inspect}".chomp }
    end
end
