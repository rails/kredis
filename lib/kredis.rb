require "kredis/railtie"
require "kredis/version"

require "kredis/connections"
require "kredis/namespace"
require "kredis/types"
require "kredis/attributes"

module Kredis
  include Connections
  include Namespace
  include Types

  extend self

  mattr_accessor :logger

  def redis(config: :shared)
    configured_for(config)
  end
end
