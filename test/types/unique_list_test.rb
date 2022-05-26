require "test_helper"

class UniqueListTest < ActiveSupport::TestCase
  setup { @list = Kredis.unique_list "myuniquelist", limit: 5 }

  test "append" do
    @list.append(%w[ 1 2 3 ])
    @list.append(%w[ 1 2 3 4 ])
    assert_equal %w[ 1 2 3 4 ], @list.elements

    @list << "5"
    assert_equal %w[ 1 2 3 4 5 ], @list.elements
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

  test "typed as integers" do
    @list = Kredis.unique_list "mylist", typed: :integer

    @list.append [ 1, 2 ]
    @list << 2
    assert_equal [ 1, 2 ], @list.elements

    @list.remove(2)
    assert_equal [ 1 ], @list.elements

    @list.append [ "1-a", 2 ]

    assert_equal [ 1, 2 ], @list.elements
  end

  test "exists?" do
    assert_not @list.exists?

    @list.append [ 1, 2 ]
    assert @list.exists?
  end

  test "appending over limit" do
    @list.append(%w[ 1 2 3 4 5 ])
    @list.append(%w[ 6 7 8 ])
    assert_equal %w[ 4 5 6 7 8 ], @list.elements
  end

  test "prepending over limit" do
    @list.prepend(%w[ 1 2 3 4 5 ])
    @list.prepend(%w[ 6 7 8 ])
    assert_equal %w[ 8 7 6 5 4 ], @list.elements
  end

  test "appending array with duplicates" do
    @list.append(%w[ 1 1 1 ])
    assert_equal %w[ 1 ], @list.elements
  end

  test "prepending array with duplicates" do
    @list.prepend(%w[ 1 1 1 ])
    assert_equal %w[ 1 ], @list.elements
  end
end
