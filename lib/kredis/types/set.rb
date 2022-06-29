class Kredis::Types::Set < Kredis::Types::Proxying
  proxying :smembers, :sadd, :srem, :multi, :del, :sismember, :scard, :spop, :exists?

  attr_accessor :typed

  def members
    value = exists? ? smembers : initialize_with_default || []
    strings_to_types(value, typed).sort
  end
  alias to_a members

  def add(*members)
    sadd types_to_strings(members, typed) if members.flatten.any?
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
    spop
  end

  def clear
    del
  end

  private
    def initialize_with_default
      default do |default_value|
        add(default_value)
        members
      end
    end
end
