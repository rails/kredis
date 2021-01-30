require "redis"

module Kredis::Connections
  mattr_accessor :connections, default: Hash.new
  mattr_accessor :configurator

  def configured_for(name)
    connections[name] ||= Redis.new configurator.config_for("redis/#{name}")
  end

  def clear_all
    logger&.info "[Kredis] Cleared all connections"
    connections.each_value(&:flushdb)
  end
end
