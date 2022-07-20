class Kredis::Types::Set < Kredis::Types::Proxying
  proxying :smembers, :sadd, :srem, :multi, :del, :sismember, :scard, :spop, :exists?, :callnx

  attr_accessor :typed

  def members
    values = init_default_in_multi { smembers }
    strings_to_types(values || [], typed).sort
  end
  alias to_a members

  def add(*members)
    return size if members.flatten.blank?

    init_default_in_multi do
      sadd types_to_strings(members, typed)
    end
  end
  alias << add

  def remove(*members)
    return size if members.flatten.blank?

    init_default_in_multi do
      srem types_to_strings(members, typed)
    end
  end

  def replace(*members)
    return size if members.flatten.blank?

    multi do
      del
      add members
    end[-1]
  end

  def include?(member)
    init_default_in_multi { sismember type_to_string(member, typed) }
  end

  def size
    init_default_in_multi { scard }.to_i
  end

  def take
    init_default_in_multi { spop }
  end

  def clear
    del
  end

  private
    def set_default(members)
      callnx(:sadd, types_to_strings(Array(members), typed))
    end
end
