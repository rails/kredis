require "test_helper"

class StringTest < ActiveSupport::TestCase
  setup { @string = Kredis.string "mystring" }

  test "assign" do
    assert_nil @string.value

    @string.value = "Something!"
    assert_equal "Something!", @string.value
  end

  test "assigned?" do
    assert_not @string.assigned?

    @string.value = "Something!"
    assert @string.assigned?
  end

  test "clear" do
    @string.value = "Something!"
    assert @string.assigned?

    @string.clear
    assert_not @string.assigned?
  end
end
