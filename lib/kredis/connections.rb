require "redis"

module Kredis::Connections
  mattr_accessor :connections, default: Hash.new
  mattr_accessor :configurator

  def configured_for(name)
    connections[name] ||= begin
      Kredis.instrument :meta, message: "Connected to #{name}"
      Redis.new configurator.config_for("redis/#{name}")
    end
  end

  def clear_all
    Kredis.instrument :meta, message: "Connections all cleared"
    connections.each_value do |connection|
      if Kredis.namespace
        keys = connection.keys("#{Kredis.namespace}:*")
        connection.del keys if keys.any?
      else
        connection.flushdb
      end
    end
  end
end
