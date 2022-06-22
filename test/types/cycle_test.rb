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

  test "with expires_in" do
    @cycle = Kredis.cycle "mycycle", values: %i[ one two ], expires_in: 25.seconds
    @cycle.next

    assert @cycle.ttl.between?(20, 25)
  end

  test "with expires_at" do
    @cycle = Kredis.cycle "mycycle", values: %i[ one two ], expires_at: Time.current + 25.seconds
    @cycle.next

    assert @cycle.ttl.between?(20, 25)
  end

  test "failing open" do
    stub_redis_down(@cycle) { @cycle.next }
    assert_equal :one, @cycle.value
  end
end
