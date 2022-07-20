class Kredis::Types::Scalar < Kredis::Types::Proxying
  proxying :set, :get, :exists?, :del, :expire, :expireat, :multi

  attr_accessor :typed, :expires_in

  def value=(value)
    set type_to_string(value, typed), ex: expires_in
  end

  def value
    get_value = multi do
      initialize_with_default
      get
    end[-1]
    string_to_type(get_value, typed)
  end

  def to_s
    value.to_s
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
