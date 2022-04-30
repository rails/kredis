class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush, :exists?, :del

  attr_accessor :typed

  def elements
    strings_to_types(lrange(0, -1) || [], typed)
  end
  alias to_a elements

  def remove(*elements, pipeline: nil)
    types_to_strings(elements, typed).each { |element| (pipeline || proxy).lrem 0, element }
  end

  def prepend(*elements, pipeline: nil)
    (pipeline || proxy).lpush types_to_strings(elements, typed) if elements.flatten.any?
  end

  def append(*elements, pipeline: nil)
    (pipeline || proxy).rpush types_to_strings(elements, typed) if elements.flatten.any?
  end
  alias << append

  def clear
    del
  end
end
