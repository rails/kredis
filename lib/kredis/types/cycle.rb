class Kredis::Types::Cycle < Kredis::Types::Counter
  attr_accessor :values

  def callback_operations
    %i[next].freeze
  end

  alias index value

  def value
    values[index]
  end

  def next
    set (index + 1) % values.size
  end
end
