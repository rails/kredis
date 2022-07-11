require "active_support/core_ext/module/delegation"

class Kredis::Types::Proxying
  attr_accessor :proxy, :key

  delegate :failsafe, to: :proxy

  def self.proxying(*commands)
    delegate *commands, to: :proxy
  end

  def initialize(redis, key, **options)
    @key = key
    @proxy = Kredis::Types::Proxy.new(redis, key)
    options.each { |key, value| send("#{key}=", value) }
  end

  private
    delegate :type_to_string, :string_to_type, :types_to_strings, :strings_to_types, to: :Kredis
end
