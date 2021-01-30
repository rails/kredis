require "test_helper"

class FlagTest < ActiveSupport::TestCase
  setup { @flag = Kredis.flag "myflag" }

  test "mark" do
    assert_not @flag.marked?

    @flag.mark
    assert @flag.marked?

    @flag.remove
    assert_not @flag.marked?
  end
end
