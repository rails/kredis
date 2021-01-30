require "test_helper"

class IntegerTest < ActiveSupport::TestCase
  setup { @integer = Kredis.integer "myinteger" }

  test "value" do
    @integer.assign = 5
    assert_equal 5, @integer.value
    assert_equal "5", @integer.value.to_s
  end
end
