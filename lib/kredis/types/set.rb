class Kredis::Types::Set < Kredis::Types::Proxying
  proxying :smembers, :sadd, :srem, :multi, :del, :sismember, :scard, :spop, :exists?

  attr_accessor :typed

  def members
    value = exists? ? smembers : default || []
    strings_to_types(value, typed).sort
  end
  alias to_a members

  def add(*members, pipeline: nil)
    (pipeline || proxy).sadd types_to_strings(members, typed) if members.flatten.any?
  end
  alias << add

  def remove(*members, pipeline: nil)
    (pipeline || proxy).srem types_to_strings(members, typed) if members.flatten.any?
  end

  def replace(*members)
    multi do |pipeline|
      pipeline.del
      add members, pipeline: pipeline
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

    def default
      return @default unless @default.is_a? Proc

      add(@default.call)
      members
    end
end
