require "test_helper"
require "active_support/core_ext/integer"

class ScalarTest < ActiveSupport::TestCase
  test "string" do
    string = Kredis.scalar "myscalar"
    string.value = "Something!"
    assert_equal "Something!", string.value
  end

  test "integer" do
    integer = Kredis.scalar "myscalar", typed: :integer
    integer.value = 5
    assert_equal 5, integer.value
  end

  test "decimal" do
    decimal = Kredis.decimal "myscalar"
    decimal.value = 5.to_d
    assert_equal 5.to_d, decimal.value
  end

  test "float" do
    float = Kredis.float "myscalar"
    float.value = 5.7
    assert_equal 5.7, float.value
  end

  test "boolean" do
    boolean = Kredis.boolean "myscalar"
    boolean.value = true
    assert_equal true, boolean.value
  end

  test "datetime" do
    datetime = Kredis.datetime "myscalar"
    datetime.value = 5.days.from_now.midnight
    assert_equal 5.days.from_now.midnight, datetime.value

    datetime.value += 0.5.seconds
    assert_equal 5.days.from_now.midnight + 0.5.seconds, datetime.value

    datetime.value = nil
    assert_nil datetime.value
  end

  test "json" do
    json = Kredis.json "myscalar"
    json.value = { "one" => 1, "string" => "hello" }
    assert_equal({ "one" => 1, "string" => "hello" }, json.value)
  end

  test "invalid type" do
    nothere = Kredis.scalar "myscalar", typed: :nothere
    nothere.value = true

    assert_raises(Kredis::TypeCasting::InvalidType) { nothere.value }
  end

  test "assigned?" do
    string = Kredis.string "myscalar"
    assert_not string.assigned?

    string.value = "Something!"
    assert string.assigned?
  end

  test "clear" do
    string = Kredis.string "myscalar"
    string.value = "Something!"
    string.clear
    assert_not string.assigned?
  end

  test "default" do
    integer = Kredis.scalar "myscalar", typed: :integer, default: 8
    assert_equal 8, integer.value

    integer.value = 5
    assert_equal 5, integer.value

    integer.clear
    assert_equal 8, integer.value

    assert_equal "8", integer.value.to_s

    json = Kredis.json "myscalar", default: { "one" => 1, "string" => "hello" }
    assert_equal({ "one" => 1, "string" => "hello" }, json.value)
  end

  test "returns default when failing open" do
    integer = Kredis.scalar "myscalar", typed: :integer, default: 8
    integer.value = 42

    stub_redis_down(integer) { assert_equal 8, integer.value }
  end

  test "telling a scalar to expire in a relative amount of time" do
    string = Kredis.scalar "myscalar", default: "unassigned"
    string.value = "assigned"
    assert_changes "string.value", from: "assigned", to: "unassigned" do
      string.expire_in 1.second
      sleep 1.1.seconds
    end
  end

  test "telling a scaler to expire at a specific point in time" do
    string = Kredis.scalar "myscalar", default: "the default"
    string.value = "assigned"
    assert_changes "string.value", from: "assigned", to: "the default" do
      string.expire_at 1.second.from_now
      sleep 1.1.seconds
    end
  end

  test "configuring a scaler to always expire after assignment" do
    forever_string = Kredis.scalar "forever", default: "unassigned", lifespan: nil
    ephemeral_string = Kredis.scalar "ephemeral", default: "unassigned", lifespan: 1.second

    forever_string.value = "assigned"
    ephemeral_string.value = "assigned"

    assert_no_changes "forever_string.value" do
      assert_changes "ephemeral_string.value", from: "assigned", to: "unassigned" do
        sleep 1.1.seconds
      end
    end
  end
end
