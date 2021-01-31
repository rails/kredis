class Kredis::Types::String < Kredis::Types::Proxy
  def value=(value)
    set value
  end

  def value
    get
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
end
