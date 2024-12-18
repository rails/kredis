# frozen_string_literal: true

class Kredis::Types::List < Kredis::Types::Proxying
  prepend Kredis::DefaultValues

  proxying :lrange, :lrem, :lpush, :ltrim, :rpush, :exists?, :del, :llen

  attr_accessor :typed

  def elements(start = 0, stop = -1)
    strings_to_types(lrange(start, stop) || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    types_to_strings(elements, typed).each { |element| lrem 0, element }
  end

  def prepend(*elements)
    lpush types_to_strings(elements, typed) if elements.flatten.any?
  end

  def append(*elements)
    rpush types_to_strings(elements, typed) if elements.flatten.any?
  end
  alias << append

  def clear
    del
  end

  def first(n = nil)
    n ? elements(0, n - 1) : elements(0, 0).first
  end

  def last(n = nil)
    n ? elements(-n, -1) : elements(-1, -1).first
  end

  def size
    llen
  end

  alias length size

  private
    def set_default
      append default
    end
end
