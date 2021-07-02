require "test_helper"

class ProxyingAfterChangeTest < ActiveSupport::TestCase
  class AfterChanger < Kredis::Types::Proxying
    invoke_after_change_on :value=, :reset

    def value
      proxy.get
    end

    def value=(value)
      proxy.set value
    end

    def reset
      proxy.del
    end
  end

  test "after_change is invoked on value=" do
    after_change_invoked = false

    changer = new_changer ->(_) { after_change_invoked = true }
    changer.value = "hey"

    assert after_change_invoked
  end

  test "after_change is invoked on clear" do
    after_change_invoked = false

    changer = new_changer ->(_) { after_change_invoked = true }
    changer.reset

    assert after_change_invoked
  end

  test "after_change yields type for value access" do
    value = nil

    changer = new_changer ->(type) { value = type.value }
    changer.value = "hey"

    assert_equal "hey", value
  end

  private
    def new_changer(after_change)
      AfterChanger.new Kredis.configured_for(:shared), "changer:1", after_change: after_change
    end
end
