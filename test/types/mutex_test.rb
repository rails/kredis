require "test_helper"

class MutexTest < ActiveSupport::TestCase
  setup { @mutex = Kredis.mutex "mymutex" }

  test "locking" do
    @mutex.lock
    assert @mutex.locked?

    @mutex.unlock
    assert_not @mutex.locked?
  end

  test "synchronize" do
    @mutex.synchronize do
      assert @mutex.locked?
    end

    assert_not @mutex.locked?
  end
end
