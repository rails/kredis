class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush

  attr_accessor :typed

  def elements
    strings_to_types(lrange(0, -1) || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    types_to_strings(elements).each { |element| lrem 0, element }

    yield send(:elements) if block_given?
  end

  def prepend(*elements)
    lpush types_to_strings(elements) if elements.flatten.any?

    # if called from a subclass/in a multi, don't yield from here
    yield send(:elements) if block_given? && !(self.class < Kredis::Types::List)
  end

  def append(*elements)
    rpush types_to_strings(elements) if elements.flatten.any?

    # if called from a subclass/in a multi, don't yield from here
    yield send(:elements) if block_given? && !(self.class < Kredis::Types::List)
  end
  alias << append
end
