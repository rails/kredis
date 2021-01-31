class Kredis::Types::Integer < Kredis::Types::String
  def value
    get&.to_i
  end

  def to_s
    value.to_s
  end
end
