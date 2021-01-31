class Kredis::Types::String < Kredis::Types::Proxy
  def assign=(value)
    set value
  end

  def assigned?
    exists?
  end

  def value
    get
  end

  def to_s
    value.to_s
  end

  def clear
    del
  end
end
