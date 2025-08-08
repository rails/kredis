# frozen_string_literal: true

class Kredis::Types::Set < Kredis::Types::Proxying
  prepend Kredis::DefaultValues
  include Kredis::Expiration

  proxying :smembers, :sadd, :srem, :multi, :del, :sismember, :scard, :spop, :exists?, :srandmember, :smove

  attr_accessor :typed
  def move(set, member)
    destination = set.respond_to?(:key) ? set.key : set
    smove(destination, member)
  end
  def members
    strings_to_types(smembers || [], typed).sort
  end
  alias to_a members

  def add(*members)
    return unless members.flatten.any?

    with_expiration do
      sadd types_to_strings(members, typed)
    end
  end
  alias << add

  def remove(*members)
    srem types_to_strings(members, typed) if members.flatten.any?
  end

  def replace(*members)
    multi do
      del
      add members
    end
  end

  def include?(member)
    sismember type_to_string(member, typed)
  end

  def size
    scard.to_i
  end

  def take
    string_to_type(spop, typed)
  end

  def clear
    del
  end

  def sample(count = nil)
    if count.nil?
      string_to_type(srandmember(count), typed)
    else
      strings_to_types(srandmember(count), typed)
    end
  end

  private
    def set_default
      add default
    end
end
