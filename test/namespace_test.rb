# frozen_string_literal: true

require "test_helper"

class NamespaceTest < ActiveSupport::TestCase
  teardown { Kredis.thread_namespace = nil }

  test "list with per-thread namespace" do
    Kredis.thread_namespace = "test-1"
    list = Kredis.list "mylist"
    list.append "one"
    assert_equal [ "one" ], list.elements

    # Aliased to thread_namespace= for back-compat
    Kredis.namespace = "test-2"
    list = Kredis.list "mylist"
    assert_equal [], list.elements

    Kredis.namespace = "test-1"
    list = Kredis.list "mylist"
    assert_equal [ "one" ], list.elements
  end
end
