require "test_helper"
require "active_support/log_subscriber/test_helper"

class LogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  teardown { ActiveSupport::LogSubscriber.log_subscribers.clear }

  test "proxy" do
    ActiveSupport::LogSubscriber.colorize_logging = true
    ActiveSupport::LogSubscriber.attach_to :kredis, Kredis::LogSubscriber.new

    instrument "proxy.kredis", message: "foo"

    assert_equal 1, @logger.logged(:debug).size
    assert_match(
      /\e\[1m\e\[33m  Kredis Proxy \(\d+\.\d+ms\)  foo\e\[0m/,
      @logger.logged(:debug).last
    )
  end

  test "migration" do
    ActiveSupport::LogSubscriber.colorize_logging = true
    ActiveSupport::LogSubscriber.attach_to :kredis, Kredis::LogSubscriber.new

    instrument "migration.kredis", message: "foo"

    assert_equal 1, @logger.logged(:debug).size
    assert_match(
      /\e\[1m\e\[33m  Kredis Migration \(\d+\.\d+ms\)  foo\e\[0m/,
      @logger.logged(:debug).last
    )
  end

  test "meta" do
    ActiveSupport::LogSubscriber.colorize_logging = true
    ActiveSupport::LogSubscriber.attach_to :kredis, Kredis::LogSubscriber.new

    instrument "meta.kredis", message: "foo"

    assert_equal 1, @logger.logged(:info).size
    assert_match(
      /\e\[1m\e\[35m  Kredis  \(\d+\.\d+ms\)  foo\e\[0m/,
      @logger.logged(:info).last
    )
  end

  private
    def instrument(...)
      ActiveSupport::Notifications.instrument(...)
      wait
    end
end
