# frozen_string_literal: true

require "redis"

module Kredis::Connections
  mattr_accessor :connections, default: Hash.new
  mattr_accessor :configurator
  mattr_accessor :connector, default: ->(config) { Redis.new(config) }

  def configured_for(name)
    connections[name] ||= Kredis.instrument :meta, message: "Connected to #{name}" do
      connector.call configurator.config_for("redis/#{name}")
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
