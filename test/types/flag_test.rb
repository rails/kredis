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

  test "expiring mark" do
    @flag.mark(expires_in: 1.second)
    assert @flag.marked?

    sleep 0.5.seconds
    assert @flag.marked?

    sleep 0.6.seconds
    assert_not @flag.marked?
  end

  test "mark unless exists" do
    assert @flag.mark(expires_in: 1.second, unless_exists: true)
    assert @flag.mark(expires_in: 1.second)
    assert @flag.mark(expires_in: 1.second, unless_exists: false)
    assert_not @flag.mark(expires_in: 10.seconds, unless_exists: true)

    assert @flag.marked?

    sleep 0.5.seconds
    assert @flag.marked?

    sleep 0.6.seconds
    assert_not @flag.marked?
  end
end
