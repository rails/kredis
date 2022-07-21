class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush, :exists?, :del, :callnx

  attr_accessor :typed

  def elements
    values = init_default_in_multi { lrange(0, -1) }
    strings_to_types(values || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    return [] if elements.flatten.blank?

    init_default_in_multi do
      types_to_strings(elements, typed).each { |element| lrem 0, element }
    end
  end

  def prepend(*elements)
    return self.elements.count if elements.flatten.blank?

    init_default_in_multi do
      lpush types_to_strings(elements, typed)
    end
  end

  def append(*elements)
    return self.elements.count if elements.flatten.blank?

    init_default_in_multi do
      rpush types_to_strings(elements, typed)
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
