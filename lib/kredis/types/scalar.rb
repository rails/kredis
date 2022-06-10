class Kredis::Types::Scalar < Kredis::Types::Proxying
  proxying :set, :get, :exists?, :del, :expire, :expireat

  attr_accessor :typed, :default, :expires_in

  def value=(value)
    set type_to_string(value, typed), ex: expires_in
  end

  def value
    value_after_casting = string_to_type(get, typed)

    if value_after_casting.nil?
      string_to_type(default_value, typed)
    else
      value_after_casting
    end
  end

  def to_s
    get || default_value&.to_s
  end

  def assigned?
    exists?
  end

  def clear
    del
  end

  def expire_in(seconds)
    expire seconds.to_i
  end

  def expire_at(datetime)
    expireat datetime.to_i
  end
end
