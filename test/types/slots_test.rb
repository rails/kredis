require "test_helper"

class SlotsTest < ActiveSupport::TestCase
  setup { @slots = Kredis.slots "myslots", available: 3 }

  test "reserve until no availability" do
    assert @slots.reserve
    assert @slots.available?

    assert @slots.reserve
    assert @slots.available?

    assert @slots.reserve
    assert_not @slots.available?

    assert_not @slots.reserve
  end

  test "reserve and release" do
    @slots.reserve
    @slots.reserve
    @slots.reserve
    assert_not @slots.available?

    @slots.release
    assert @slots.available?
  end

  test "release when slots are reserved" do
    assert_not @slots.release

    3.times do
      assert @slots.reserve
    end

    3.times do
      assert @slots.release
    end

    assert_not @slots.release

    assert_equal 0, @slots.taken
  end

  test "reserve with block" do
    assert @slots.reserve
    assert @slots.reserve

    assert(@slots.reserve {
      assert_not @slots.available?
      false # ensure that block return value isn't returned from #reserve
    })

    assert @slots.available?
  end

  test "failed reserve with block" do
    assert @slots.reserve
    assert @slots.reserve
    assert @slots.reserve

    ran = false

    assert_not(@slots.reserve {
      ran = true
    })

    assert_not ran
  end

  test "reset" do
    3.times do
      assert @slots.reserve
    end

    @slots.reset

    3.times do
      assert @slots.reserve
    end
  end

  test "single slot" do
    slot = Kredis.slot "myslot"
    assert slot.reserve
    assert_not slot.available?
  end

  test "release single slot when reserved" do
    slot = Kredis.slot "myslot"

    assert_not slot.release

    assert slot.reserve
    assert slot.release

    assert_not slot.release
  end

  test "failing open" do
    stub_redis_down(@slots) do
      assert_not @slots.available?

      assert_not @slots.reserve

      ran = false
      assert_not @slots.reserve { ran = true }
      assert_not ran
    end
  end

  test "exists?" do
    assert_not @slots.exists?

    @slots.reserve
    assert @slots.exists?
  end
end
