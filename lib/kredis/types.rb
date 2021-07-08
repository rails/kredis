module Kredis::Types
  def proxy(key, config: :shared)
    Proxy.new configured_for(config), namespaced_key(key)
  end


  def scalar(key, typed: :string, default: nil, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: typed, default: default
  end

  def string(key, default: nil, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :string, default: default
  end

  def integer(key, default: nil, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :integer, default: default
  end

  def decimal(key, default: nil, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :decimal, default: default
  end

  def float(key, default: nil, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :float, default: default
  end

  def boolean(key, default: nil, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :boolean, default: default
  end

  def datetime(key, default: nil, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :datetime, default: default
  end

  def json(key, default: nil, config: :shared)
    Scalar.new configured_for(config), namespaced_key(key), typed: :json, default: default
  end


  def counter(key, expires_in: nil, config: :shared)
    Counter.new configured_for(config), namespaced_key(key), expires_in: expires_in
  end

  def cycle(key, values:, expires_in: nil, config: :shared)
    Cycle.new configured_for(config), namespaced_key(key), values: values, expires_in: expires_in
  end

  def flag(key, config: :shared)
    Flag.new configured_for(config), namespaced_key(key)
  end

  def enum(key, values:, default:, config: :shared)
    Enum.new configured_for(config), namespaced_key(key), values: values, default: default
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


  def with_callback(type, key, **options)
    callback = options.delete(:after_change)
    Kredis::CallbacksProxy.new(Kredis.send(type, key, **options), nil, callback)
  end
end

require "kredis/types/proxy"
require "kredis/types/proxying"

require "kredis/types/scalar"
require "kredis/types/counter"
require "kredis/types/cycle"
require "kredis/types/flag"
require "kredis/types/enum"
require "kredis/types/list"
require "kredis/types/unique_list"
require "kredis/types/set"
require "kredis/types/slots"
