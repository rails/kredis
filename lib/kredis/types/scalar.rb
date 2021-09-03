class Kredis::Types::Scalar < Kredis::Types::Proxying
  proxying :set, :get, :exists?, :del

  attr_accessor :typed, :default

  def value=(value)
    set type_to_string(value)
  end

  def value
    value_after_casting = string_to_type(get, typed)
    
    if value_after_casting.nil?
      default
    else
      value_after_casting
    end
  end

  def to_s
    get || default&.to_s
  end

  def assigned?
    exists?
  end

  def clear
    del
  end
end
