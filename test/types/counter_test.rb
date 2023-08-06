# frozen_string_literal: true

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

  test "exists?" do
    assert_not @counter.exists?

    @counter.increment
    assert @counter.exists?
  end

  test "default value" do
    @counter = Kredis.counter "mycounter", default: 10
    assert_equal 10, @counter.value
  end

  test "expiring counter with default" do
    @counter = Kredis.counter "mycounter", default: ->() { 10 }, expires_in: 1.second

    @counter.increment
    assert_equal 11, @counter.value

    sleep 0.5.seconds

    @counter.increment
    assert_equal 12, @counter.value

    sleep 0.5.seconds

    # Defaults are only set on initialization
    assert_equal 0, @counter.value
  end

  test "default via proc" do
    @counter = Kredis.counter "mycounter", default: ->() { 10 }
    assert_equal 10, @counter.value
    @counter.decrement
    assert_equal 9, @counter.value
  end

  test "concurrent initialization with default" do
    5.times.map do
      Thread.new do
        Kredis.counter("mycounter", default: 5).increment
      end
    end.each(&:join)

    assert_equal 10, Kredis.counter("mycounter").value
  end
end
