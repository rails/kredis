module Kredis::Types
  def proxy(key, config: :shared)
    Proxy.new configured_for(config), namespaced_key(key)
  end

  def string(key, config: :shared)
    String.new configured_for(config), namespaced_key(key)
  end

  def integer(key, config: :shared)
    Integer.new configured_for(config), namespaced_key(key)
  end

  def counter(key, expires_in: nil, config: :shared)
    Counter.new configured_for(config), namespaced_key(key), expires_in: expires_in
  end

  def flag(key, config: :shared)
    Flag.new configured_for(config), namespaced_key(key)
  end

  def enum(key, values:, default:, config: :shared)
    Enum.new configured_for(config), namespaced_key(key), values: values, default: default
  end

  def json(key, config: :shared)
    Json.new configured_for(config), namespaced_key(key)
  end

  def list(key, config: :shared)
    List.new configured_for(config), namespaced_key(key)
  end

  def unique_list(key, limit: nil, config: :shared)
    UniqueList.new configured_for(config), namespaced_key(key), limit: limit
  end

  def set(key, config: :shared)
    Set.new configured_for(config), namespaced_key(key)
  end

  def slot(key, config: :shared)
    Slots.new configured_for(config), namespaced_key(key), available: 1
  end

  def slots(key, available:, config: :shared)
    Slots.new configured_for(config), namespaced_key(key), available: available
  end
end

require "kredis/types/proxy"

require "kredis/types/string"
require "kredis/types/integer"
require "kredis/types/counter"
require "kredis/types/flag"
require "kredis/types/enum"
require "kredis/types/json"
require "kredis/types/list"
require "kredis/types/unique_list"
require "kredis/types/set"
require "kredis/types/slots"
