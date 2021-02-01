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
end
