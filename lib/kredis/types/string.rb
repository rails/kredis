class Kredis::Types::String < Kredis::Proxy
  def assign=(value)
    set value
  end

  def assigned?
    exists?
  end

  def value
    get
  end

  def clear
    del
  end
end
