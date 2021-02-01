class Kredis::Types::Proxy
  attr_accessor :redis, :key

  def initialize(redis, key, **options)
    @redis, @key = redis, key
    options.each { |key, value| send("#{key}=", value) }
  end

  def multi(...)
    redis.multi(...)
  end

  def method_missing(method, *args, **kwargs)
    Kredis.logger&.debug log_message(method, *args, **kwargs)
    redis.public_send method, key, *args, **kwargs
  end

  private
    def log_message(method, *args, **kwargs)
      args      = args.flatten.compact_blank.presence
      kwargs    = kwargs.compact_blank.presence
      type_name = self.class.name.split("::").last

      "[Kredis #{type_name}] #{method.upcase} #{key} #{args&.inspect} #{kwargs&.inspect}".chomp
    end
end
