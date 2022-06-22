class Kredis::Types::Cycle < Kredis::Types::Counter
  include Kredis::Types::Expirable.on(:next)

  attr_accessor :values

  alias index value

  def value
    values[index]
  end

  def next
    set (index + 1) % values.size
  end
end
