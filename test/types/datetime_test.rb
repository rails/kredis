require "test_helper"
require "active_support/core_ext/integer"

class DatetimeTest < ActiveSupport::TestCase
  setup { @datetime = Kredis.datetime "mydatetime" }

  test "value with nothing stored" do
    assert_nil @datetime.value
  end

  test "value" do
    freeze_time
    @datetime.value = 5.minutes.ago
    assert_equal 5.minutes.ago, @datetime.value
    assert_equal 5.minutes.ago.to_s, @datetime.value.to_s
    assert_equal 5.minutes.ago.to_f, @datetime.to_f
  end
end
