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

  private
    def assert_threaded(&block)
      yield # Run on current thread.
      Thread.new(&block).join
    end
end
