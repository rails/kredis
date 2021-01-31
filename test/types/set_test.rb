require "test_helper"

class SetTest < ActiveSupport::TestCase
  setup { @set = Kredis.set "myset" }

  test "add" do
    @set.add(%w[ 1 2 3 ])
    @set << 4
    @set << 4
    assert_equal %w[ 1 2 3 4 ], @set.elements
  end

  test "add nothing" do
    @set.add(%w[ 1 2 3 ])
    @set.add([])
    assert_equal %w[ 1 2 3 ], @set.to_a
  end

  test "remove" do
    @set.add(%w[ 1 2 3 4 ])
    @set.remove(%w[ 2 3 ])
    @set.remove("1")
    assert_equal %w[ 4 ], @set.elements
  end

  test "remove nothing" do
    @set.add(%w[ 1 2 3 4 ])
    @set.remove([])
    assert_equal %w[ 1 2 3 4 ], @set.elements
  end

  test "includes" do
    @set.add(%w[ 1 2 3 4 ])
    assert @set.includes?("1")
    assert_not @set.includes?("5")
  end

  test "size" do
    @set.add(%w[ 1 2 3 4 ])
    assert_equal 4, @set.size
  end

  test "take" do
    @set.add("1")
    assert_equal "1", @set.take

    @set.add(%w[ 1 2 3 4 ])
    assert @set.take.in? %w[ 1 2 3 4 ]
  end

  test "clear" do
    @set.add("1")
    @set.clear
    assert_equal [], @set.elements
  end
end
