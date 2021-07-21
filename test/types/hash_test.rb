require "test_helper"
require "active_support/core_ext/integer"

class HashTest < ActiveSupport::TestCase
  setup { @hash = Kredis.hash "myhash" }

  test "set" do
    @hash.set(key: :value)
    @hash.set("key2" => "value2", "key3" => "value3")
    assert_equal({ "key" => "value", "key2" => "value2", "key3" => "value3" }, @hash.to_h)
  end

  test "get" do
    @hash.set("key2" => "value2", "key3" => "value3")
    assert_equal "value2", @hash.get("key2")
    assert_equal "value3", @hash.get("key3")
    assert_equal %w[ value2 value3 ], @hash.get("key2", "key3")
    assert_nil @hash.get("key")
  end

  test "keys" do
    @hash.set(key: :value)
    @hash.set("key2" => "value2", "key3" => "value3")
    assert_equal %w[ key key2 key3 ], @hash.keys
  end

  test "values" do
    @hash.set(key: :value)
    @hash.set("key2" => "value2", "key3" => "value3")
    assert_equal %w[ value value2 value3 ], @hash.values
  end
end
