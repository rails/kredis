require "active_support/core_ext/module/delegation"

class Kredis::Types::List < Kredis::Types::Proxy
  attr_accessor :typed

  def elements
    Kredis.strings_to_types(lrange(0, -1) || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    Kredis.types_to_strings(elements).each { |element| lrem 0, element }
  end

  def prepend(*elements)
    lpush Kredis.types_to_strings(elements) if Array(elements).flatten.any?
  end

  def append(*elements)
    rpush Kredis.types_to_strings(elements) if Array(elements).flatten.any?
  end
  alias << append
end
