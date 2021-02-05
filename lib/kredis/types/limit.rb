class Kredis::Types::Limit < Kredis::Types::Counter
  attr_accessor :bound

  def exceeded?
    value >= bound
  end
end
