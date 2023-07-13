# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/module/attribute_accessors_per_thread"

require "kredis/version"

require "kredis/connections"
require "kredis/log_subscriber"
require "kredis/namespace"
require "kredis/type_casting"
require "kredis/default_values"
require "kredis/types"
require "kredis/attributes"

require "kredis/railtie" if defined?(Rails::Railtie)

module Kredis
  include Connections, Namespace, TypeCasting, Types
  extend self

  autoload :Migration, "kredis/migration"

  mattr_accessor :logger

  def redis(config: :shared)
    configured_for(config)
  end

  def instrument(channel, **options, &block)
    ActiveSupport::Notifications.instrument("#{channel}.kredis", **options, &block)
  end
end
