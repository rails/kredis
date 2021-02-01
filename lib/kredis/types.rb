module Kredis::Types
  def proxy(key, config: :shared)
    Proxy.new configured_for(config), namespaced_key(key)
  end


  def scalar(key, typed: :string, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: typed
  end

  def string(key, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :string
  end

  def integer(key, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :integer
  end

  def decimal(key, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :decimal
  end

  def float(key, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :float
  end

  def boolean(key, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :boolean
  end

  def datetime(key, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :datetime
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

  def list(key, typed: :string, config: :shared)
    List.new configured_for(config), namespaced_key(key), typed: typed
  end

  def unique_list(key, typed: :string, limit: nil, config: :shared)
    UniqueList.new configured_for(config), namespaced_key(key), typed: typed, limit: limit
  end

  def set(key, typed: :string, config: :shared)
    Set.new configured_for(config), namespaced_key(key), typed: typed
  end

  def slot(key, config: :shared)
    Slots.new configured_for(config), namespaced_key(key), available: 1
  end

  def slots(key, available:, config: :shared)
    Slots.new configured_for(config), namespaced_key(key), available: available
  end
end

require "kredis/types/proxy"
require "kredis/types/proxying"

require "kredis/types/scalar"
require "kredis/types/counter"
require "kredis/types/flag"
require "kredis/types/enum"
require "kredis/types/json"
require "kredis/types/list"
require "kredis/types/unique_list"
require "kredis/types/set"
require "kredis/types/slots"
