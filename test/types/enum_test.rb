require "test_helper"

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
  end

  test "validated value" do
    assert @enum.one?

    @enum.value = "nonesense"
    assert @enum.one?
  end

  test "reset" do
    @enum.value = "two"
    assert @enum.two?

    @enum.reset
    assert @enum.one?
  end
end
