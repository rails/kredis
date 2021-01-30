require "test_helper"

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
    @counter.increment by: 2
    assert_equal 2, @counter.value
  end

  test "expiring counter" do
    @counter = Kredis.counter "mycounter", expires_in: 1

    @counter.increment
    assert_equal 1, @counter.value

    sleep 1.1

    assert_equal 0, @counter.value
  end
end
