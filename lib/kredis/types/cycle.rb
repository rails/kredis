class Kredis::Types::Cycle < Kredis::Types::Counter
  invoke_after_change_on :next

  attr_accessor :values

  alias index value

  def value
    values[index]
  end

  def next
    set (index + 1) % values.size
  end
end
