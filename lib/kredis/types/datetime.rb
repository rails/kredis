class Kredis::Types::Datetime < Kredis::Types::String
  def value
    if value = get&.to_i
      Time.at value
    end
  end

  def value=(value)
    super value.to_f
  end
end
