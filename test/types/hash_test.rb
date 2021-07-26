require "test_helper"
require "active_support/core_ext/integer"

class HashTest < ActiveSupport::TestCase
  setup { @hash = Kredis.hash "myhash" }

  test "update" do
    @hash.update(key: :value)
    @hash.update("key2" => "value2", "key3" => "value3")
    assert_equal({ "key" => "value", "key2" => "value2", "key3" => "value3" }, @hash.to_h)
  end

  test "reading" do
    @hash.update("key2" => "value2", "key3" => "value3")
    assert_equal "value2", @hash["key2"]
    assert_equal "value3", @hash[:key3]
    assert_equal %w[ value2 value3 ], @hash.values_at("key2", "key3")
    assert_nil @hash["key"]
  end

  test "delete" do
    @hash.update(key: :value)
    @hash.update("key2" => "value2", "key3" => "value3")
    assert_equal({ "key" => "value", "key2" => "value2", "key3" => "value3" }, @hash.to_h)

    @hash.delete("key", "key2")
    assert_equal({ "key3" => "value3" }, @hash.to_h)
  end

  test "keys" do
    @hash.update(key: :value)
    @hash.update("key2" => "value2", "key3" => "value3")
    assert_equal %w[ key key2 key3 ], @hash.keys
  end

  test "values" do
    @hash.update(key: :value)
    @hash.update("key2" => "value2", "key3" => "value3")
    assert_equal %w[ value value2 value3 ], @hash.values
  end

  test "typed as integer" do
    @hash = Kredis.hash "myhash", typed: :integer
    @hash.update(space_invaders: 100, pong: 42)

    assert_equal %w[ space_invaders pong ], @hash.keys
    assert_equal [ 100, 42 ], @hash.values
    assert_equal 100, @hash[:space_invaders]
    assert_equal 42, @hash["pong"]
    assert_equal({ "space_invaders" => 100, "pong" => 42 }, @hash.to_h)
  end
end
