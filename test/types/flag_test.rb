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

  test "mark with force" do
    assert @flag.mark(expires_in: 1.second, force: false)
    assert @flag.mark(expires_in: 1.second)
    assert @flag.mark(expires_in: 1.second, force: true)
    assert_not @flag.mark(expires_in: 10.seconds, force: false)

    assert @flag.marked?

    sleep 0.5.seconds
    assert @flag.marked?

    sleep 0.6.seconds
    assert_not @flag.marked?
  end
end
