class Kredis::Types::Hash < Kredis::Types::Proxying
  proxying :hset, :hmget, :hgetall, :hdel, :hkeys, :hvals

  attr_accessor :typed

  def entries
    Hash[*strings_to_types(hgetall || {}, typed)]
  end
  alias to_h entries

  def set(**entries)
    hset types_to_strings(entries) if entries.flatten.any?
  end

  def get(*keys)
    values = strings_to_types(hmget(keys) || [], typed)
    values.size == 1 ? values.first : values
  end

  def del(*keys)
    hdel types_to_strings(keys) if keys.flatten.any?
  end

  def keys
    strings_to_types(hkeys || [], typed)
  end

  def values
    strings_to_types(hvals || [], typed)
  end
end
