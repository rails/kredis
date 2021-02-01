class Kredis::Types::Scalar < Kredis::Types::Proxying
  proxying :set, :get, :exists?, :del

  attr_accessor :typed

  def value=(value)
    set type_to_string(value)
  end

  def value
    string_to_type(get, typed)
  end

  def to_s
    get
  end

  def assigned?
    exists?
  end

  def clear
    del
  end
end
