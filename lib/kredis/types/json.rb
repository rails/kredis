class Kredis::Types::Json < Kredis::Types::Proxy
  def value=(value)
    set JSON.dump(value)
  end

  def value
    if json = get
      JSON.load(json)
    end
  end

  def to_h
    value || {}
  end

  def assigned?
    exists?
  end
end
