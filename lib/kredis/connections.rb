require "redis"

module Kredis::Connections
  mattr_accessor :connections, default: Hash.new
  mattr_accessor :configurator

  def configured_for(name)
    connections[name] ||= begin
      logger&.info "[Kredis] Connected to #{name}"
      Redis.new configurator.config_for("redis/#{name}")
    end
  end

  def clear_all
    logger&.info "[Kredis] Connections all cleared"
    connections.each_value(&:flushdb)
  end
end
