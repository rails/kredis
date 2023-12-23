# frozen_string_literal: true

class Kredis::Types::List < Kredis::Types::Proxying
  prepend Kredis::DefaultValues

  proxying :lrange, :lrem, :lpush, :ltrim, :rpush, :exists?, :del, :expire

  attr_accessor :typed, :expires_in

  def elements
    strings_to_types(lrange(0, -1) || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    types_to_strings(elements, typed).each { |element| lrem 0, element }
  end

  def prepend(*elements)
    return if elements.flatten.empty?

    lpush types_to_strings(elements, typed)
    expire_in expires_in if expires_in
    elements
  end

  def append(*elements)
    return if elements.flatten.empty?

    rpush types_to_strings(elements, typed)
    expire_in expires_in if expires_in
    elements
  end
  alias << append

  def clear
    del
  end

  def last(n = nil)
    n ? lrange(-n, -1) : lrange(-1, -1).first
  end

  def expire_in(seconds)
    expire seconds.to_i
  end

  private
    def set_default
      append default
    end
end
