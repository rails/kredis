class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush, :exists?, :del, :multi, :callnx

  attr_accessor :typed

  def elements
    values = multi do
      initialize_with_default
      lrange(0, -1)
    end[-1]
    strings_to_types(values || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    return if elements.empty?

    multi do
      initialize_with_default
      types_to_strings(elements, typed).each { |element| lrem 0, element }
    end
  end

  def prepend(*elements)
    return if elements.empty?

    multi do
      initialize_with_default
      lpush types_to_strings(elements, typed) if elements.flatten.any?
    end
  end

  def append(*elements)
    return if elements.empty?

    multi do
      initialize_with_default
      rpush types_to_strings(elements, typed) if elements.flatten.any?
    end
  end
  alias << append

  def clear
    del
  end

  private
    def set_default(elements)
      callnx(:rpush, types_to_strings(Array(elements), typed))
    end
end
