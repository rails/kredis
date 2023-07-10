# frozen_string_literal: true

require "test_helper"

class OrderedSetTest < ActiveSupport::TestCase
  setup { @set = Kredis.ordered_set "ordered-set", limit: 5 }

  test "append" do
    @set.append(%w[ 1 2 3 ])
    @set.append(%w[ 1 2 3 4 ])
    assert_equal %w[ 1 2 3 4 ], @set.elements

    @set << "5"
    assert_equal %w[ 1 2 3 4 5 ], @set.elements
  end

  test "appending the same element re-appends it" do
    @set.append(%w[ 1 2 3 ])
    @set.append(%w[ 2 ])
    assert_equal %w[ 1 3 2 ], @set.elements
  end

  test "mass append maintains ordering" do
    @set = Kredis.ordered_set "ordered-set" # no limit

    thousand_elements = 1000.times.map { [*"A".."Z"].sample(10).join }
    @set.append(thousand_elements)
    assert_equal thousand_elements, @set.elements

    thousand_elements.each { |element| @set.append(element) }
    assert_equal thousand_elements, @set.elements
  end

  test "prepend" do
    @set.prepend(%w[ 1 2 3 ])
    @set.prepend(%w[ 1 2 3 4 ])
    assert_equal %w[ 4 3 2 1 ], @set.elements
  end

  test "append nothing" do
    @set.append(%w[ 1 2 3 ])
    @set.append([])
    assert_equal %w[ 1 2 3 ], @set.elements
  end

  test "prepend nothing" do
    @set.prepend(%w[ 1 2 3 ])
    @set.prepend([])
    assert_equal %w[ 3 2 1 ], @set.elements
  end

  test "typed as integers" do
    @set = Kredis.ordered_set "mylist", typed: :integer

    @set.append [ 1, 2 ]
    @set << 2
    assert_equal [ 1, 2 ], @set.elements

    @set.remove(2)
    assert_equal [ 1 ], @set.elements

    @set.append [ "1-a", 2 ]

    assert_equal [ 1, 2 ], @set.elements
  end

  test "exists?" do
    assert_not @set.exists?

    @set.append [ 1, 2 ]
    assert @set.exists?
  end

  test "appending over limit" do
    @set.append(%w[ 1 2 3 4 5 ])
    @set.append(%w[ 6 7 8 ])
    assert_equal %w[ 4 5 6 7 8 ], @set.elements
  end

  test "prepending over limit" do
    @set.prepend(%w[ 1 2 3 4 5 ])
    @set.prepend(%w[ 6 7 8 ])
    assert_equal %w[ 8 7 6 5 4 ], @set.elements
  end

  test "appending array with duplicates" do
    @set.append(%w[ 1 1 1 ])
    assert_equal %w[ 1 ], @set.elements
  end

  test "prepending array with duplicates" do
    @set.prepend(%w[ 1 1 1 ])
    assert_equal %w[ 1 ], @set.elements
  end

  test "limit can't be 0 or less" do
    assert_raises do
      Kredis.ordered_set "ordered-set", limit: -1
    end
  end
end
