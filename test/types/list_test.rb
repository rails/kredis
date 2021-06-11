require "test_helper"
require "active_support/core_ext/integer"

class ListTest < ActiveSupport::TestCase
  setup { @list = Kredis.list "mylist" }

  test "append" do
    @list.append(%w[ 1 2 3 ])
    @list << 4
    assert_equal %w[ 1 2 3 4 ], @list.elements
  end

  test "append yields elements to block" do
    yielded_elements = []
    @list.append(%w[ 1 2 3 ]) do |elements|
      yielded_elements = elements
    end
    assert_equal %w[ 1 2 3 ], yielded_elements
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

  test "prepend yields elements to block" do
    yielded_elements = []
    @list.prepend(%w[ 1 2 3 ]) do |elements|
      yielded_elements = elements
    end
    assert_equal %w[ 3 2 1 ], yielded_elements
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

  test "remove yields elements to the block" do
    yielded_elements = []
    @list.append(%w[ 1 2 3 4 ])
    @list.remove(%w[ 1 2 ]) do |elements|
      yielded_elements = elements
    end
    assert_equal %w[ 3 4 ], yielded_elements
  end

  test "typed as datetime" do
    @list = Kredis.list "mylist", typed: :datetime

    @list.append [ 1.day.from_now.midnight, 2.days.from_now.midnight ]
    assert_equal [ 1.day.from_now.midnight, 2.days.from_now.midnight ], @list.elements

    @list.remove(2.days.from_now.midnight)
    assert_equal [ 1.day.from_now.midnight ], @list.elements
  end
end
