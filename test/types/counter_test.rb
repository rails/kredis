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

    assert_equal 3, @counter.increment
  end

  test "increment by 2" do
    assert_equal 0, @counter.value

    @counter.increment by: 2
    assert_equal 2, @counter.value

    assert_equal 4, @counter.increment(by: 2)
  end

  test "decrement" do
    assert_equal 0, @counter.value

    @counter.decrement
    assert_equal (-1), @counter.value

    assert_equal (-2), @counter.decrement
  end

  test "decrement by 2" do
    assert_equal 0, @counter.value

    @counter.decrement by: 2
    assert_equal (-2), @counter.value

    assert_equal (-4), @counter.decrement(by: 2)
  end

  test "with expires in" do
    @counter = Kredis.counter "mycounter", expires_in: 25.second

    @counter.increment
    assert @counter.ttl.between?(20, 25)
  end

  test "with expires at" do
    @counter = Kredis.counter "mycounter", expires_at: Time.current + 25.second

    @counter.increment
    assert @counter.ttl.between?(20, 25)
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

  test "exists?" do
    assert_not @counter.exists?

    @counter.increment
    assert @counter.exists?
  end
end
