require "active_support/core_ext/module/delegation"

class Kredis::Types::Proxying
  attr_accessor :proxy, :redis, :key

  def self.proxying(*commands)
    delegate *commands, to: :proxy
  end

  def initialize(redis, key, **options)
    @redis, @key = redis, key
    @default = options.delete(:default)
    @proxy = Kredis::Types::Proxy.new(redis, key)
    options.each { |key, value| send("#{key}=", value) }
  end

  def failsafe(returning: nil, &block)
    proxy.suppress_failsafe_with(returning: returning, &block)
  end

  private
    delegate :type_to_string, :string_to_type, :types_to_strings, :strings_to_types, to: :Kredis

    def default
      if @default.is_a?(Proc)
        @default.call
      else
        @default
      end
    end

    def initialize_with_default
      default_value = default
      set_default(default_value) if default_value.present?
    end

    def set_default(value)
      set type_to_string(value, typed), ex: expires_in, nx: true
    end
end
