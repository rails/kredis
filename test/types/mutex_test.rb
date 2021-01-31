require "test_helper"

class MutexTest < ActiveSupport::TestCase
  setup { @mutex = Kredis.mutex "mymutex" }

  test "locking" do
    @mutex.lock
    assert_threaded { assert @mutex.locked? }

    @mutex.unlock
    assert_threaded { assert_not @mutex.locked? }
  end

  test "synchronize" do
    @mutex.synchronize do
      assert_threaded { assert @mutex.locked? }
    end

    assert_threaded { assert_not @mutex.locked? }
  end

  test "locked by another concurrent lock" do
    @mutex.lock
    assert @mutex.locked?

    other_mutex = Kredis.mutex "mymutex"
    assert_not other_mutex.lock, "someone without the lock can't lock"
    assert other_mutex.locked?

    assert_nil other_mutex.unlock, "someone without the lock can't unlock"
    @mutex.unlock

    assert_not @mutex.locked?
    assert_not other_mutex.locked?
  end

  private
    def assert_threaded(&block)
      yield # Run on current thread.
      Thread.new(&block).join
    end
end
