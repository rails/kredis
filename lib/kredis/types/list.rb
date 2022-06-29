class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush, :exists?, :del

  attr_accessor :typed

  def elements
    value = exists? ? lrange(0, -1) : initialize_with_default || []
    strings_to_types(value, typed)
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
    def initialize_with_default
      default do |default_value|
        append(default_value)
        elements
      end
    end
end
