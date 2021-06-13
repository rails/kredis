class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush

  include Kredis::Types::Callbacks

  attr_accessor :typed

  def elements
    strings_to_types(lrange(0, -1) || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    run_callbacks :change do
      types_to_strings(elements).each { |element| lrem 0, element }
    end
  end

  def prepend(*elements)
    run_callbacks :change do
      lpush types_to_strings(elements) if elements.flatten.any?
    end
  end

  def append(*elements)
    run_callbacks :change do
      rpush types_to_strings(elements) if elements.flatten.any?
    end
  end
  alias << append
end
