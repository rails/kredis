require "test_helper"
require "active_support/core_ext/integer"

class ListTest < ActiveSupport::TestCase
  setup { @list = Kredis.list "mylist" }

  test "append" do
    @list.append(%w[ 1 2 3 ])
    @list << 4
    assert_equal %w[ 1 2 3 4 ], @list.elements
    assert_equal -1, @list.ttl
  end

  test "append with expires_in" do
    @list.expires_in = 25
    @list.append(%w[ 1 2 3 ])
    assert @list.ttl.between?(20, 25)
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

  test "prepend with expires_in" do
    @list.expires_in = 25
    @list.prepend(%w[ 1 2 3 ])
    assert @list.ttl.between?(20, 25)
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

  test "remove with expires_in" do
    @list.append(%w[ 1 2 3 4 ])
    assert_equal -1, @list.ttl

    @list.expires_in = 25
    @list.remove(%w[ 1 2 ])
    assert @list.ttl.between?(20, 25)
  end

  test "clear" do
    @list.append(%w[ 1 2 3 4 ])
    @list.clear
    assert_equal [], @list.elements
  end

  test "typed as datetime" do
    @list = Kredis.list "mylist", typed: :datetime

    @list.append [ 1.day.from_now.midnight, 2.days.from_now.midnight ]
    assert_equal [ 1.day.from_now.midnight, 2.days.from_now.midnight ], @list.elements

    @list.remove(2.days.from_now.midnight)
    assert_equal [ 1.day.from_now.midnight ], @list.elements
  end

  test "exists?" do
    assert_not @list.exists?

    @list.append(%w[ 1 2 3 ])
    assert @list.exists?
  end
end
