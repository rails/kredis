require "test_helper"

class NamespaceTest < ActiveSupport::TestCase
  test "list with namespace" do
    Kredis.namespace = "test-1"
    list = Kredis.list "mylist"
    list.append "one"
    assert_equal [ "one" ], list.elements

    Kredis.namespace = "test-2"
    list = Kredis.list "mylist"
    assert_equal [], list.elements

    Kredis.namespace = "test-1"
    list = Kredis.list "mylist"
    assert_equal [ "one" ], list.elements
  end
end
