# frozen_string_literal: true

require "redis"

module Kredis::Connections
  DEFAULT_REDIS_URL     = "redis://127.0.0.1:6379/0"
  DEFAULT_REDIS_TIMEOUT = 1

  mattr_accessor :connections, default: Hash.new
  mattr_accessor :configurator
  mattr_accessor :connector, default: ->(config) { Redis.new(config) }

  def configured_for(name)
    connections[name] ||= Kredis.instrument :meta, message: "Connected to #{name}" do
      if configurator.root.join("config/redis/#{name}.yml").exist?
        connector.call configurator.config_for("redis/#{name}")
      elsif name == :shared
        Redis.new url: ENV.fetch("REDIS_URL", DEFAULT_REDIS_URL), timeout: DEFAULT_REDIS_TIMEOUT
      else
        raise "No configuration found for #{name}"
      end
    end
  end

  def clear_all
    Kredis.instrument :meta, message: "Connections all cleared" do
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
end
