class Kredis::Types::Set < Kredis::Types::Proxying
  proxying :smembers, :sadd, :srem, :multi, :del, :sismember, :scard, :spop

  include Kredis::Types::Callbacks

  attr_accessor :typed

  def members
    strings_to_types(smembers || [], typed).sort
  end
  alias to_a members

  def add(*members)
    sadd types_to_strings(members) if members.flatten.any?

    @changed_callback&.call(self)
  end
  alias << add

  def remove(*members)
    srem types_to_strings(members) if members.flatten.any?

    @changed_callback&.call(self)
  end

  def replace(*members)
    multi do
      del
      add members
    end

    @changed_callback&.call(self)
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
