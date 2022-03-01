class Kredis::Types::Proxy
  require_relative "proxy/failsafe"
  include Failsafe

  attr_accessor :redis, :key, :pipeline

  def initialize(redis, key, **options)
    @redis, @key = redis, key
    options.each { |key, value| send("#{key}=", value) }
  end

  def multi(*args, **kwargs, &block)
    redis.multi(*args, **kwargs) do |pipeline|
      self.pipeline = pipeline
      block.call
      self.pipeline = nil
    end
  end

  def method_missing(method, *args, **kwargs)
    Kredis.instrument :proxy, **log_message(method, *args, **kwargs) do
      failsafe do
        (pipeline || redis).public_send method, key, *args, **kwargs
      end
    end
  end

  private
    def log_message(method, *args, **kwargs)
      args      = args.flatten.reject(&:blank?).presence
      kwargs    = kwargs.reject { |_k, v| v.blank? }.presence

      { message: "#{method.upcase} #{key} #{args&.inspect} #{kwargs&.inspect}".chomp }
    end
end
