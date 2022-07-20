require "active_support/core_ext/hash"

class Kredis::Types::Hash < Kredis::Types::Proxying
  proxying :hset, :hdel, :hgetall, :del, :exists?, :multi, :callnx

  attr_accessor :typed

  def [](key)
    string_to_type(entries[key], typed)
  end

  def []=(key, value)
    update key => value
  end


  def update(**entries)
    multi do
      initialize_with_default
      hset entries.transform_values{ |val| type_to_string(val, typed) } if entries.flatten.any?
    end
  end

  def values_at(*keys)
    strings_to_types(entries.values_at(*keys) || [], typed)
  end

  def delete(*keys)
    multi do
      initialize_with_default
      hdel keys if keys.flatten.any?
    end
  end

  def remove
    del
  end
  alias clear remove

  def entries
    (hgetall.presence || default || {}).transform_values { |val| string_to_type(val, typed) }.with_indifferent_access
  end
  alias to_h entries

  def keys
    entries.keys || []
  end

  def values
    strings_to_types(entries.values || [], typed)
  end

  private
    def set_default(entries)
      callnx(:hset, entries.transform_values{ |val| type_to_string(val, typed) })
    end
end
