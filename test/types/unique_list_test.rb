require "test_helper"

class UniqueListTest < ActiveSupport::TestCase
  setup { @list = Kredis.unique_list "myuniquelist" }

  test "append" do
    @list.append(%w[ 1 2 3 ])
    @list.append(%w[ 1 2 3 4 ])
    assert_equal %w[ 1 2 3 4 ], @list.elements
  end

  test "prepend" do
    @list.prepend(%w[ 1 2 3 ])
    @list.prepend(%w[ 1 2 3 4 ])
    assert_equal %w[ 4 3 2 1 ], @list.elements
  end

  test "append nothing" do
    @list.append(%w[ 1 2 3 ])
    @list.append([])
    assert_equal %w[ 1 2 3 ], @list.elements
  end

  test "prepend nothing" do
    @list.prepend(%w[ 1 2 3 ])
    @list.prepend([])
    assert_equal %w[ 3 2 1 ], @list.elements
  end
end
