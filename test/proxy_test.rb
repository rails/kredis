require "test_helper"

class ProxyTest < ActiveSupport::TestCase
  setup { @proxy = Kredis.keyed "something" }

  test "proxy set and get and del" do
    @proxy.set "one"
    assert_equal "one", @proxy.get

    @proxy.del
    assert_nil @proxy.get
  end
end
