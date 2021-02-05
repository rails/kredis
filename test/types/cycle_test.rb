require "test_helper"
require "active_support/core_ext/integer"

class CycleTest < ActiveSupport::TestCase
  setup { @cycle = Kredis.cycle "mycycle", values: %i[ one two three ] }

  test "next" do
    assert_equal :one, @cycle.value

    @cycle.next
    assert_equal :two, @cycle.value

    @cycle.next
    assert_equal :three, @cycle.value

    @cycle.next
    assert_equal :one, @cycle.value
  end

  test "failing open" do
    stub_redis_down(@cycle) { @cycle.next }
    assert_equal :one, @cycle.value
  end
end
