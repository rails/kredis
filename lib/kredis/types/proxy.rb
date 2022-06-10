class Kredis::Types::Proxy
  require_relative "proxy/failsafe"
  include Failsafe

  attr_accessor :redis, :key

  def initialize(redis, key, **options)
    @redis, @key = redis, key
    @default = options.delete(:default)
    options.each { |key, value| send("#{key}=", value) }
  end

  def multi(&block)
    # NOTE: to be removed when Redis 4 compatibility gets dropped
    return redis.multi unless block

    redis.multi do |pipeline|
      block.call(Kredis::Types::Proxy.new(pipeline, key))
    end
  end

  def get
    super || default
  end

  def default
    return @default unless @default.is_a? Proc

    @default.call.tap { |value| set(value) unless value.nil? }
  end

  def method_missing(method, *args, **kwargs)
    Kredis.instrument :proxy, **log_message(method, *args, **kwargs) do
      failsafe do
        redis.public_send method, key, *args, **kwargs
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
