require "active_support/core_ext/hash"

class Kredis::Types::Hash < Kredis::Types::Proxying
  proxying :hget, :hset, :hmget, :hgetall, :hdel, :hkeys, :hvals

  attr_accessor :typed

  def entries
    (hgetall || {}).transform_values { |val| string_to_type(val, typed) }.with_indifferent_access
  end
  alias to_h entries

  def update(**entries)
    hset types_to_strings(entries) if entries.flatten.any?
  end

  def [](key)
    string_to_type(hget(key), typed)
  end

  def values_at(*keys)
    strings_to_types(hmget(keys) || [], typed)
  end

  def delete(*keys)
    hdel types_to_strings(keys) if keys.flatten.any?
  end

  def keys
    hkeys || []
  end

  def values
    strings_to_types(hvals || [], typed)
  end
end
