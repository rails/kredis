require "test_helper"
require "active_support/log_subscriber/test_helper"

class LogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  setup do
    ActiveSupport::LogSubscriber.colorize_logging = true
    ActiveSupport::LogSubscriber.attach_to :kredis, Kredis::LogSubscriber.new
  end

  teardown { ActiveSupport::LogSubscriber.log_subscribers.clear }

  test "proxy" do
    instrument "proxy.kredis", message: "foo", type: "bar"

    assert_equal 1, @logger.logged(:debug).size
    assert_match(
      /\e\[1m\e\[33mKredis bar \(\d+\.\d+ms\)\e\[0m  \e\[1m\e\[33mfoo\e\[0m/,
      @logger.logged(:debug).last
    )
  end

  test "migration" do
    instrument "migration.kredis", message: "foo"

    assert_equal 1, @logger.logged(:debug).size
    assert_match(
      /\e\[1m\e\[33mKredis Migration \(\d+\.\d+ms\)\e\[0m  \e\[1m\e\[33mfoo\e\[0m/,
      @logger.logged(:debug).last
    )
  end

  test "meta" do
    instrument "meta.kredis", message: "foo"

    assert_equal 1, @logger.logged(:info).size
    assert_match(
      /\e\[1m\e\[35mKredis \(\d+\.\d+ms\)\e\[0m  \e\[1m\e\[35mfoo\e\[0m/,
      @logger.logged(:info).last
    )
  end

  private
    def instrument(...)
      ActiveSupport::Notifications.instrument(...)
      wait
    end
end
