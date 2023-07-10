# frozen_string_literal: true

class Kredis::Types::Cycle < Kredis::Types::Counter
  attr_accessor :values

  alias index value

  def value
    values[index]
  end

  def next
    set (index + 1) % values.size
  end
end
