require "test_helper"

class ConnectionsTest < ActiveSupport::TestCase
  test "clear all" do
    list = Kredis.list "mylist"
    list.append "one"
    assert_equal [ "one" ], list.elements

    Kredis.clear_all
    assert_equal [], list.elements
  end
end
