class Kredis::Types::Datetime < Kredis::Types::String
  def value
    Time.at get&.to_i
  end

  def value=(value)
    super value.to_f
  end
end
