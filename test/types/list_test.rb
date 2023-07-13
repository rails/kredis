# frozen_string_literal: true

require "test_helper"
require "active_support/core_ext/integer"

class ListTest < ActiveSupport::TestCase
  setup { @list = Kredis.list "mylist" }

  test "append" do
    @list.append(%w[ 1 2 3 ])
    @list << 4
    assert_equal %w[ 1 2 3 4 ], @list.elements
  end

  test "append nothing" do
    @list.append(%w[ 1 2 3 ])
    @list.append([])
    assert_equal %w[ 1 2 3 ], @list.to_a
  end

  test "prepend" do
    @list.prepend(%w[ 1 2 3 ])
    @list.prepend(4)
    assert_equal %w[ 4 3 2 1 ], @list.elements
  end

  test "prepend nothing" do
    @list.prepend("1", "2", "3")
    @list.prepend([])
    assert_equal %w[ 3 2 1 ], @list.elements
  end

  test "remove" do
    @list.append(%w[ 1 2 3 4 ])
    @list.remove(%w[ 1 2 ])
    @list.remove(3)
    assert_equal %w[ 4 ], @list.elements
  end

  test "clear" do
    @list.append(%w[ 1 2 3 4 ])
    @list.clear
    assert_equal [], @list.elements
  end

  test "last" do
    @list.append(%w[ 1 2 3 ])
    assert_equal "3", @list.last
  end

  test "last(n)" do
    @list.append(%w[ 1 2 3 ])
    assert_equal %w[ 2 3 ], @list.last(2)
  end

  test "typed as datetime" do
    @list = Kredis.list "mylist", typed: :datetime

    @list.append [ 1.day.from_now.midnight.in_time_zone("Pacific Time (US & Canada)"), 2.days.from_now.midnight.in_time_zone("UTC") ]
    assert_equal [ 1.day.from_now.midnight, 2.days.from_now.midnight ], @list.elements

    @list.remove(2.days.from_now.midnight)
    assert_equal [ 1.day.from_now.midnight ], @list.elements
  end

  test "exists?" do
    assert_not @list.exists?

    @list.append(%w[ 1 2 3 ])
    assert @list.exists?
  end

  test "ltrim" do
    @list.append(%w[ 1 2 3 4 ])
    @list.ltrim(-3, -2)
    assert_equal %w[ 2 3 ], @list.elements
  end
end
