class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush

  attr_accessor :typed

  def elements
    strings_to_types(lrange(0, -1) || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    types_to_strings(elements).each { |element| lrem 0, element }
  end

  def prepend(*elements)
    lpush types_to_strings(elements) if elements.flatten.any?
  end

  def append(*elements)
    rpush types_to_strings(elements) if elements.flatten.any?
  end
  alias << append
end
