require "kredis/railtie"
require "kredis/version"

require "kredis/connections"
require "kredis/namespace"
require "kredis/types"
require "kredis/attributes"

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
