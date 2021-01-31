class Kredis::Types::Set < Kredis::Types::Proxy
  def elements
    smembers
  end
  alias to_a elements

  def add(elements)
    sadd elements if Array(elements).any?
  end
  alias << add

  def remove(elements)
    srem elements if Array(elements).any?
  end

  def replace(elements)
    multi do
      del
      add elements
    end
  end

  def include?(element)
    sismember(element)
  end

  def size
    scard
  end

  def take
    spop
  end

  def clear
    del
  end
end
