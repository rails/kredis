class Kredis::Types::Datetime < Kredis::Types::String
  def value=(value)
    super value.to_f
  end
  
  def value
    if value = get&.to_i
      Time.at value
    end
  end
end
