# frozen_string_literal: true

require "bundler/setup"
require "active_support/test_case"
require "active_support/testing/autorun"
require "rails/test_unit/line_filtering"
require "minitest/mock"
require "debug"

require "kredis"

Kredis.configurator = Class.new do
  def config_for(name) { db: "1" } end
  def root() Pathname.new(".") end
end.new

ActiveSupport::LogSubscriber.logger = ActiveSupport::Logger.new(STDOUT) if ENV["VERBOSE"]

class ActiveSupport::TestCase
  extend Rails::LineFiltering

  setup { Kredis.global_namespace = "kredis-test" }
  teardown { Kredis.global_namespace = nil; Kredis.clear_all }

  class RedisUnavailableProxy
    def multi; yield; end
    def pipelined; yield; end
    def method_missing(*); raise Redis::BaseError; end
  end

  def stub_redis_down(redis_holder, &block)
    redis_holder.try(:proxy) || redis_holder \
      .stub(:redis, RedisUnavailableProxy.new, &block)
  end
end
