# frozen_string_literal: true

class Kredis::Types::List < Kredis::Types::Proxying
  prepend Kredis::DefaultValues
  include Kredis::Expiration

  proxying :lrange, :lrem, :lpush, :ltrim, :rpush, :exists?, :del

  attr_accessor :typed

  def elements
    strings_to_types(lrange(0, -1) || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    types_to_strings(elements, typed).each { |element| lrem 0, element }
  end

  def prepend(*elements)
    return if elements.flatten.empty?

    with_expiration do
      lpush types_to_strings(elements, typed)
    end
  end

  def append(*elements)
    return if elements.flatten.empty?


    with_expiration do
      rpush types_to_strings(elements, typed)
    end
  end
  alias << append

  def clear
    del
  end

  def last(n = nil)
    n ? lrange(-n, -1) : lrange(-1, -1).first
  end

  private
    def set_default
      append default
    end
end
