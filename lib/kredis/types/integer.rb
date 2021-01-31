class Kredis::Types::Integer < Kredis::Types::Value
  def value
    super&.to_i
  end
end
