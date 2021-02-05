require "kredis/railtie"
require "kredis/version"

require "kredis/connections"
require "kredis/namespace"
require "kredis/type_casting"
require "kredis/types"
require "kredis/attributes"

module Kredis
  include Connections, Namespace, TypeCasting, Types

  extend self

  mattr_accessor :logger

  def redis(config: :shared)
    configured_for(config)
  end
end
