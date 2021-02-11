require "test_helper"

class ConnectionsTest < ActiveSupport::TestCase
  teardown { Kredis.namespace = nil }

  test "clear all" do
    list = Kredis.list "mylist"
    list.append "one"
    assert_equal [ "one" ], list.elements

    Kredis.clear_all
    assert_equal [], list.elements
  end

  test "clear all with namespace" do
    Kredis.configured_for(:shared).set "mykey", "don't remove me"

    Kredis.namespace = "test-1"
    integer = Kredis.integer "myinteger"
    integer.value = 1

    Kredis.clear_all

    assert_nil integer.value
    assert_equal "don't remove me", Kredis.configured_for(:shared).get("mykey")
  end
end
