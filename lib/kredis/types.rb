module Kredis::Types
  def proxy(key, config: :shared, after_change: nil)
    Proxy.new configured_for(config), namespaced_key(key), after_change: after_change
  end


  def scalar(key, typed: :string, default: nil, config: :shared, after_change: nil)
    Scalar.new configured_for(config), namespaced_key(key), typed: typed, default: default, after_change: after_change
  end

  def string(key, default: nil, config: :shared, after_change: nil)
    Scalar.new configured_for(config), namespaced_key(key), typed: :string, default: default, after_change: after_change
  end

  def integer(key, default: nil, config: :shared, after_change: nil)
    Scalar.new configured_for(config), namespaced_key(key), typed: :integer, default: default, after_change: after_change
  end

  def decimal(key, default: nil, config: :shared, after_change: nil)
    Scalar.new configured_for(config), namespaced_key(key), typed: :decimal, default: default, after_change: after_change
  end

  def float(key, default: nil, config: :shared, after_change: nil)
    Scalar.new configured_for(config), namespaced_key(key), typed: :float, default: default, after_change: after_change
  end

  def boolean(key, default: nil, config: :shared, after_change: nil)
    Scalar.new configured_for(config), namespaced_key(key), typed: :boolean, default: default, after_change: after_change
  end

  def datetime(key, default: nil, config: :shared, after_change: nil)
    Scalar.new configured_for(config), namespaced_key(key), typed: :datetime, default: default, after_change: after_change
  end

  def json(key, default: nil, config: :shared, after_change: nil)
    Scalar.new configured_for(config), namespaced_key(key), typed: :json, default: default, after_change: after_change
  end


  def counter(key, expires_in: nil, config: :shared, after_change: nil)
    Counter.new configured_for(config), namespaced_key(key), expires_in: expires_in, after_change: after_change
  end

  def cycle(key, values:, expires_in: nil, config: :shared, after_change: nil)
    Cycle.new configured_for(config), namespaced_key(key), values: values, expires_in: expires_in, after_change: after_change
  end

  def flag(key, config: :shared, after_change: nil)
    Flag.new configured_for(config), namespaced_key(key), after_change: after_change
  end

  def enum(key, values:, default:, config: :shared, after_change: nil)
    Enum.new configured_for(config), namespaced_key(key), values: values, default: default, after_change: after_change
  end

  def list(key, typed: :string, config: :shared, after_change: nil)
    List.new configured_for(config), namespaced_key(key), typed: typed, after_change: after_change
  end

  def unique_list(key, typed: :string, limit: nil, config: :shared, after_change: nil)
    UniqueList.new configured_for(config), namespaced_key(key), typed: typed, limit: limit, after_change: after_change
  end

  def set(key, typed: :string, config: :shared, after_change: nil)
    Set.new configured_for(config), namespaced_key(key), typed: typed, after_change: after_change
  end

  def slot(key, config: :shared, after_change: nil)
    Slots.new configured_for(config), namespaced_key(key), available: 1, after_change: after_change
  end

  def slots(key, available:, config: :shared, after_change: nil)
    Slots.new configured_for(config), namespaced_key(key), available: available, after_change: after_change
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
