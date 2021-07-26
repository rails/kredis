require "test_helper"
require "active_support/log_subscriber/test_helper"

class LogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  setup do
    @log_subscriber = Kredis::LogSubscriber.new
  end

  teardown do
    ActiveSupport::LogSubscriber.log_subscribers.clear
  end

  test "#proxy" do
    ActiveSupport::LogSubscriber.colorize_logging = true
    ActiveSupport::LogSubscriber.attach_to :kredis, @log_subscriber
    instrument "proxy.kredis", message: "foo", type: "bar"
    wait

    assert_equal 1, @logger.logged(:debug).size
    assert_match(
      /\e\[1m\e\[33mKredis bar \(\d+\.\d+ms\)\e\[0m  \e\[1m\e\[33mfoo\e\[0m/,
      @logger.logged(:debug).last
    )
  end

  test "#migration" do
    ActiveSupport::LogSubscriber.colorize_logging = true
    ActiveSupport::LogSubscriber.attach_to :kredis, @log_subscriber
    instrument "migration.kredis", message: "foo"
    wait

    assert_equal 1, @logger.logged(:debug).size
    assert_match(
      /\e\[1m\e\[33mKredis Migration \(\d+\.\d+ms\)\e\[0m  \e\[1m\e\[33mfoo\e\[0m/,
      @logger.logged(:debug).last
    )
  end

  test "#meta" do
    ActiveSupport::LogSubscriber.colorize_logging = true
    ActiveSupport::LogSubscriber.attach_to :kredis, @log_subscriber
    instrument "meta.kredis", message: "foo"
    wait

    assert_equal 1, @logger.logged(:info).size
    assert_match(
      /\e\[1m\e\[35mKredis \(\d+\.\d+ms\)\e\[0m  \e\[1m\e\[35mfoo\e\[0m/,
      @logger.logged(:info).last
    )
  end

  private

  def instrument(*args, &block)
    ActiveSupport::Notifications.instrument(*args, &block)
  end
end
