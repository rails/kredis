require "test_helper"
require "active_support/core_ext/integer"

class CounterTest < ActiveSupport::TestCase
  setup { @counter = Kredis.counter "mycounter" }

  test "increment" do
    assert_equal 0, @counter.value

    @counter.increment
    assert_equal 1, @counter.value

    @counter.increment
    assert_equal 2, @counter.value
  end

  test "increment by 2" do
    assert_equal 0, @counter.value

    @counter.increment by: 2
    assert_equal 2, @counter.value
  end

  test "decrement" do
    assert_equal 0, @counter.value

    @counter.decrement
    assert_equal (-1), @counter.value
  end

  test "decrement by 2" do
    assert_equal 0, @counter.value

    @counter.decrement by: 2
    assert_equal (-2), @counter.value
  end

  test "expiring counter" do
    @counter = Kredis.counter "mycounter", expires_in: 1.second

    @counter.increment
    assert_equal 1, @counter.value

    sleep 0.5.seconds

    @counter.increment
    assert_equal 2, @counter.value

    sleep 0.6.seconds

    assert_equal 0, @counter.value
  end

  test "reset" do
    @counter.increment
    assert_equal 1, @counter.value

    @counter.reset
    assert_equal 0, @counter.value
  end

  test "failing open" do
    stub_redis_down(@counter) { @counter.increment }
    assert_equal 0, @counter.value
  end
end
