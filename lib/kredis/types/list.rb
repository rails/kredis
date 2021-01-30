class Kredis::Types::List < Kredis::Proxy
  def elements
    lrange(0, -1) || []
  end

  def remove(elements)
    Array(elements).each { |element| lrem 0, element }
  end

  def prepend(elements)
    lpush elements
  end

  def append(elements)
    rpush elements
  end
end
