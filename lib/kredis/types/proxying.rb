require "active_support/core_ext/module/delegation"
require "kredis/types/before_method_hook"

class Kredis::Types::Proxying
  extend Kredis::Types::BeforeMethodHook
  
  attr_accessor :proxy, :redis, :key

  def self.proxying(*commands)
    delegate *commands, to: :proxy
  end

  def initialize(redis, key, **options)
    @redis, @key = redis, key
    @default = options.delete(:default)
    @proxy = Kredis::Types::Proxy.new(redis, key, default: ->() { default })
    options.each { |key, value| send("#{key}=", value) }
  end

  def failsafe(returning: nil, &block)
    proxy.suppress_failsafe_with(returning: returning, &block)
  end

  private
    delegate :type_to_string, :string_to_type, :types_to_strings, :strings_to_types, to: :Kredis

    def default
      return @default unless @default.is_a? Proc

      @default.call.tap { |value| set(value) unless value.nil? }
    end
end
