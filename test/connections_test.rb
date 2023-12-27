# frozen_string_literal: true

require "test_helper"
require "yaml"

class ConnectionsTest < ActiveSupport::TestCase
  setup { Kredis.connections = {} }
  teardown { Kredis.namespace = nil }

  test "clear all" do
    list = Kredis.list "mylist"
    list.append "one"
    assert_equal [ "one" ], list.elements

    Kredis.clear_all
    assert_equal [], list.elements
  end

  test "clear all with namespace" do
    Kredis.configured_for(:shared).set "mykey", "don't remove me"

    Kredis.namespace = "test-1"
    integer = Kredis.integer "myinteger"
    integer.value = 1

    Kredis.clear_all

    assert_nil integer.value
    assert_equal "don't remove me", Kredis.configured_for(:shared).get("mykey")
  end

  test "config from file" do
    fixture_config = YAML.load_file(Pathname.new(Dir.pwd).join("test/fixtures/config/redis/shared.yml"))["test"].symbolize_keys

    Kredis.configurator.stub(:config_for, fixture_config) do
      Kredis.configurator.stub(:root, Pathname.new(Dir.pwd).join("test/fixtures")) do
        assert_match %r|redis://127.0.0.1:6379/4|, Kredis.redis.inspect
      end
    end
  end

  test "default config in env" do
    ENV["REDIS_URL"] = "redis://127.0.0.1:6379/3"
    assert_match %r|redis://127.0.0.1:6379/3|, Kredis.redis.inspect
  ensure
    ENV.delete("REDIS_URL")
  end

  test "default config without env" do
    assert_match %r|redis://127.0.0.1:6379/0|, Kredis.redis.inspect
  end
end
