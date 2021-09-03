module Kredis::Types
  autoload :CallbacksProxy, "kredis/types/callbacks_proxy"

  def proxy(key, config: :shared, after_change: nil)
    type_from(Proxy, config, key, after_change: after_change)
  end


  def scalar(key, typed: :string, default: nil, config: :shared, after_change: nil)
    type_from(Scalar, config, key, after_change: after_change, typed: typed, default: default)
  end

  def string(key, default: nil, config: :shared, after_change: nil)
    type_from(Scalar, config, key, after_change: after_change, typed: :string, default: default)
  end

  def integer(key, default: nil, config: :shared, after_change: nil)
    type_from(Scalar, config, key, after_change: after_change, typed: :integer, default: default)
  end

  def decimal(key, default: nil, config: :shared, after_change: nil)
    type_from(Scalar, config, key, after_change: after_change, typed: :decimal, default: default)
  end

  def float(key, default: nil, config: :shared, after_change: nil)
    type_from(Scalar, config, key, after_change: after_change, typed: :float, default: default)
  end

  def boolean(key, default: nil, config: :shared, after_change: nil)
    type_from(Scalar, config, key, after_change: after_change, typed: :boolean, default: default)
  end

  def datetime(key, default: nil, config: :shared, after_change: nil)
    type_from(Scalar, config, key, after_change: after_change, typed: :datetime, default: default)
  end

  def json(key, default: nil, config: :shared, after_change: nil)
    type_from(Scalar, config, key, after_change: after_change, typed: :json, default: default)
  end


  def counter(key, expires_in: nil, config: :shared, after_change: nil)
    type_from(Counter, config, key, after_change: after_change, expires_in: expires_in)
  end

  def cycle(key, values:, expires_in: nil, config: :shared, after_change: nil)
    type_from(Cycle, config, key, after_change: after_change, values: values, expires_in: expires_in)
  end

  def flag(key, config: :shared, after_change: nil)
    type_from(Flag, config, key, after_change: after_change)
  end

  def enum(key, values:, default:, config: :shared, after_change: nil)
    type_from(Enum, config, key, after_change: after_change, values: values, default: default)
  end

  def hash(key, typed: :string, config: :shared, after_change: nil)
    type_from(Hash, config, key, after_change: after_change, typed: typed)
  end

  def list(key, typed: :string, config: :shared, after_change: nil)
    type_from(List, config, key, after_change: after_change, typed: typed)
  end

  def unique_list(key, typed: :string, limit: nil, config: :shared, after_change: nil)
    type_from(UniqueList, config, key, after_change: after_change, typed: typed, limit: limit)
  end

  def set(key, typed: :string, config: :shared, after_change: nil)
    type_from(Set, config, key, after_change: after_change, typed: typed)
  end

  def slot(key, config: :shared, after_change: nil)
    type_from(Slots, config, key, after_change: after_change, available: 1)
  end

  def slots(key, available:, config: :shared, after_change: nil)
    type_from(Slots, config, key, after_change: after_change, available: available)
  end

  private
    def type_from(type_klass, config, key, after_change: nil, **options)
      type_klass.new(configured_for(config), namespaced_key(key), **options).then do |type|
        after_change ? CallbacksProxy.new(type, after_change) : type
      end
    end
end

require "kredis/types/proxy"
require "kredis/types/proxying"

require "kredis/types/scalar"
require "kredis/types/counter"
require "kredis/types/cycle"
require "kredis/types/flag"
require "kredis/types/enum"
require "kredis/types/hash"
require "kredis/types/list"
require "kredis/types/unique_list"
require "kredis/types/set"
require "kredis/types/slots"
