require "kredis/railtie"
require "kredis/version"

require "kredis/connections"
require "kredis/namespace"
require "kredis/types"
require "kredis/attributes"
require "kredis/type_casting"

module Kredis
  include Connections, Namespace, Types, TypeCasting

  extend self

  mattr_accessor :logger

  def redis(config: :shared)
    configured_for(config)
  end
end
