class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush, :exists?, :del

  attr_accessor :typed

  def elements
    strings_to_types(lrange(0, -1) || [], typed)
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

  def last(n = nil)
    if n
      if n == 0
        []
      elsif n < 0
        raise ArgumentError, "negative array size"
      else
        lrange(-n, -1)
      end
    else
      lrange(-1, -1).first
    end
  end
end
