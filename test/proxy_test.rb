require "test_helper"

class ProxyTest < ActiveSupport::TestCase
  setup { @proxy = Kredis.proxy "something" }
  teardown { Kredis::Types::Proxy::Failsafe.enabled = true }

  test "proxy set and get and del" do
    @proxy.set "one"
    assert_equal "one", @proxy.get

    @proxy.del
    assert_nil @proxy.get
  end

  test "failing open" do
    @proxy.set "one"
    assert_equal "one", @proxy.get
    stub_redis_down(@proxy) { assert_nil @proxy.get }

    assert @proxy.set("two")
    stub_redis_down(@proxy) { assert_nil @proxy.set("two") }
  end

  test "with fail safe disabled an error is raised" do
    Kredis::Types::Proxy::Failsafe.enabled = false

    stub_redis_down(@proxy) do
      assert_raises(Redis::BaseError) { @proxy.get }
    end
  end
end
