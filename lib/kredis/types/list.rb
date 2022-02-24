class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush, :exists?, :del

  attr_accessor :typed, :default

  def elements
    raw_value = lrange(0, -1)

    if raw_value.empty?
      raw_value = list_default_evaluated
      append(raw_value)
    end

    strings_to_types(raw_value, typed)
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

  private

  def list_default_evaluated
    default.is_a?(Proc) ? default.call(self) : default
  end
end
