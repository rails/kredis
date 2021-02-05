require "active_support"
require "active_support/core_ext/module/attribute_accessors"

require "kredis/version"

require "kredis/connections"
require "kredis/namespace"
require "kredis/type_casting"
require "kredis/types"
require "kredis/attributes"

require "kredis/railtie" if defined?(Rails::Railtie)

module Kredis
  include Connections, Namespace, TypeCasting, Types

  extend self

  mattr_accessor :logger

  def redis(config: :shared)
    configured_for(config)
  end
end
