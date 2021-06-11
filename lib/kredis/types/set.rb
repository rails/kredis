class Kredis::Types::Set < Kredis::Types::Proxying
  proxying :smembers, :sadd, :srem, :multi, :del, :sismember, :scard, :spop

  attr_accessor :typed

  def members
    strings_to_types(smembers || [], typed).sort
  end
  alias to_a members

  def add(*members)
    sadd types_to_strings(members) if members.flatten.any?

    yield send(:members) if block_given?
  end
  alias << add

  def remove(*members)
    srem types_to_strings(members) if members.flatten.any?

    yield send(:members) if block_given?
  end

  def replace(*members)
    multi do
      del
      add members
    end

    yield send(:members) if block_given?
  end

  def include?(member)
    sismember type_to_string(member)
  end

  def size
    scard.to_i
  end

  def take
    spop
  end

  def clear
    del
  end
end
