class Kredis::Types::Set < Kredis::Types::Proxying
  proxying :smembers, :sadd, :srem, :multi, :del, :sismember, :scard, :spop

  include Kredis::Types::Callbacks

  attr_accessor :typed

  def members
    strings_to_types(smembers || [], typed).sort
  end
  alias to_a members

  def add(*members)
    run_callbacks :change do
      sadd types_to_strings(members) if members.flatten.any?
    end
  end
  alias << add

  def remove(*members)
    run_callbacks :change do
      srem types_to_strings(members) if members.flatten.any?
    end
  end

  def replace(*members)
    run_callbacks :change do
      multi do
        del
        add members
      end
    end
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
