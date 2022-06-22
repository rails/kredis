require "test_helper"
require "active_support/core_ext/integer"

class EnumTest < ActiveSupport::TestCase
  setup { @enum = Kredis.enum "myenum", values: %w[ one two three ], default: "one" }

  test "default" do
    assert_equal "one", @enum.value
  end

  test "predicates" do
    assert @enum.one?

    @enum.value = "two"
    assert @enum.two?

    assert_not @enum.three?

    @enum.three!
    assert @enum.three?

    assert_not @enum.two?
  end

  test "validated value" do
    assert @enum.one?

    @enum.value = "nonesense"
    assert @enum.one?
  end

  test "with expires_in" do
    @enum = Kredis.enum "myenum", values: %w[ one ], default: "one", expires_in: 25.seconds
    @enum.value = "one"

    assert @enum.ttl.between?(20, 25)
  end

  test "with expires_at" do
    @enum = Kredis.enum "myenum", values: %w[ one ], default: "one", expires_at: Time.current + 25.seconds
    @enum.value = "one"

    assert @enum.ttl.between?(20, 25)
  end

  test "reset" do
    @enum.value = "two"
    assert @enum.two?

    @enum.reset
    assert @enum.one?
  end

  test "exists?" do
    assert_not @enum.exists?

    @enum.value = "one"
    assert @enum.exists?
  end
end
