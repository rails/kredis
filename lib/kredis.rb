require "kredis/railtie"

require "kredis/connections"
require "kredis/types"
require "kredis/attributes"
require "kredis/namespace"
require "kredis/logger"

module Kredis
  include Connections
  include Namespace
  include Types

  mattr_accessor :logger

  extend self

  def redis(config: :shared)
    configured_for(config)
  end
end
