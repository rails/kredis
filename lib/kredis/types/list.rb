class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush, :exists?, :del, :default

  attr_accessor :typed

  def elements
    value = exists? ? lrange(0, -1) : default || []
    strings_to_types(value, typed)
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

  private

    def default
      return @default unless @default.is_a? Proc

      append(@default.call)
      elements
    end
end
