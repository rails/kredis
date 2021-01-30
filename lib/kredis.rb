require "kredis/railtie"

require "kredis/connections"
require "kredis/types"
require "kredis/attributes"
require "kredis/namespace"
require "kredis/logger"

module Kredis
  extend self

  mattr_accessor :logger

  include Connections
  include Namespace
  include Types

  def redis(config: :shared)
    configured_for(config)
  end
end
