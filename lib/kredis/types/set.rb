class Kredis::Types::Set < Kredis::Types::Proxy
  def members
    smembers
  end
  alias to_a members

  def add(members)
    sadd members if Array(members).any?
  end
  alias << add

  def remove(members)
    srem members if Array(members).any?
  end

  def replace(members)
    multi do
      del
      add members
    end
  end

  def include?(member)
    sismember(member)
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
