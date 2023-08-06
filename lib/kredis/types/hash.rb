# frozen_string_literal: true

require "active_support/core_ext/hash"

class Kredis::Types::Hash < Kredis::Types::Proxying
  prepend Kredis::DefaultValues

  proxying :hget, :hset, :hmget, :hdel, :hgetall, :hkeys, :hvals, :del, :exists?

  attr_accessor :typed

  def [](key)
    string_to_type(hget(key), typed)
  end

  def []=(key, value)
    update key => value
  end

  def update(**entries)
    hset entries.transform_values { |val| type_to_string(val, typed) } if entries.flatten.any?
  end

  def values_at(*keys)
    strings_to_types(hmget(keys) || [], typed)
  end

  def delete(*keys)
    hdel keys if keys.flatten.any?
  end

  def remove
    del
  end
  alias clear remove

  def entries
    (hgetall || {}).transform_values { |val| string_to_type(val, typed) }.with_indifferent_access
  end
  alias to_h entries

  def keys
    hkeys || []
  end

  def values
    strings_to_types(hvals || [], typed)
  end

  private
    def set_default
      update(**default)
    end
end
