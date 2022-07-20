class Kredis::Types::Set < Kredis::Types::Proxying
  proxying :smembers, :sadd, :srem, :multi, :del, :sismember, :scard, :spop, :exists?, :callnx

  attr_accessor :typed

  def members
    values = multi do
      initialize_with_default
      smembers
    end[-1]
    strings_to_types(values || [], typed).sort
  end
  alias to_a members

  def add(*members)
    multi do
      initialize_with_default
      sadd types_to_strings(members, typed) if members.flatten.any?
    end
  end
  alias << add

  def remove(*members)
    multi do
      initialize_with_default
      srem types_to_strings(members, typed) if members.flatten.any?
    end
  end

  def replace(*members)
    multi do
      del
      add members
    end
  end

  def include?(member)
    multi do
      initialize_with_default
      sismember type_to_string(member, typed)
    end[-1]
  end

  def size
    multi do
      initialize_with_default
      scard
    end[-1].to_i
  end

  def take
    multi do
      initialize_with_default
      spop
    end[-1]
  end

  def clear
    del
  end

  private
    def set_default(members)
      callnx(:sadd, types_to_strings(Array(members), typed))
    end
end
