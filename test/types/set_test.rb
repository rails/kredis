# frozen_string_literal: true

require "test_helper"
require "active_support/core_ext/object/inclusion"
require "active_support/core_ext/integer"

class SetTest < ActiveSupport::TestCase
  setup { @set = Kredis.set "myset" }

  test "add" do
    @set.add(%w[ 1 2 3 ])
    @set << 4
    @set << 4
    assert_equal %w[ 1 2 3 4 ], @set.members
  end

  test "add nothing" do
    @set.add(%w[ 1 2 3 ])
    @set.add([])
    assert_equal %w[ 1 2 3 ], @set.to_a
  end

  test "remove" do
    @set.add(%w[ 1 2 3 4 ])
    @set.remove([ %w[ 2 3 ] ])
    @set.remove("1")
    assert_equal %w[ 4 ], @set.members
  end

  test "remove nothing" do
    @set.add(%w[ 1 2 3 4 ])
    @set.remove([])
    assert_equal %w[ 1 2 3 4 ], @set.members
  end

  test "replace" do
    @set.add(%w[ 1 2 3 4 ])
    @set.replace(%w[ 5 6 ])
    assert_equal %w[ 5 6 ], @set.members
  end

  test "include" do
    @set.add("1", "2", "3", "4")
    assert @set.include?("1")
    assert_not @set.include?("5")

    assert "1".in?(@set)
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
    assert_equal [], @set.members
  end

  test "typed as floats" do
    @set = Kredis.set "mylist", typed: :float

    @set.add 1.5, 2.7
    @set << 2.7
    assert_equal [ 1.5, 2.7 ], @set.members

    @set.remove(2.7)
    assert_equal [ 1.5 ], @set.members

    assert_equal 1.5, @set.take
  end

  test "failing open" do
    stub_redis_down(@set) do
      @set.add "1"
      assert_equal [], @set.members
      assert_equal 0, @set.size
    end
  end

  test "exists?" do
    assert_not @set.exists?

    @set.add(%w[ 1 2 3 ])
    assert @set.exists?
  end

  test "srandmember" do
    @set = Kredis.set "mylist", typed: :float
    @set.add 1.5, 2.7

    assert @set.sample.in?([ 1.5, 2.7 ])
    assert_equal [ 1.5, 2.7 ], @set.sample(2).sort
  end

  test "default" do
    @set = Kredis.set "mylist", default: %w[ 1 2 3 ]
    assert_equal %w[ 1 2 3 ], @set.members
  end

  test "default is an empty array" do
    @set = Kredis.set "mylist", default: []
    assert_equal [], @set.members
  end

  test "default is nil" do
    @set = Kredis.set "mylist", default: nil
    assert_equal [], @set.members
  end

  test "default via proc" do
    @set = Kredis.set "mylist", default: -> () { %w[ 3 3 1 2 ] }
    assert_equal %w[ 1 2 3 ], @set.members
  end

  test "add with default" do
    @set = Kredis.set "mylist", typed: :integer, default: -> () { %w[ 1 2 3 ] }
    @set.add(%w[ 5 6 7 ])
    assert_equal [ 1, 2, 3, 5, 6, 7 ], @set.members
  end

  test "add with expiration" do
    @set = Kredis.set "mylist", typed: :integer, expires_in: 1.second
    @set.add(%w[ 1 2 3 ])

    sleep 0.7.seconds
    @set.add(%w[ 4 5 ])
    assert_equal [ 1, 2, 3, 4, 5 ], @set.members

    sleep 0.5.seconds
    assert_equal [], @set.members
  end

  test "remove with default" do
    @set = Kredis.set "mylist", default: -> () { %w[ 1 2 3 4 ] }
    @set.remove(%w[ 2 3 ])
    @set.remove("1")
    assert_equal %w[ 4 ], @set.members
  end

  test "replace with default" do
    @set = Kredis.set "mylist", typed: :integer, default: -> () { %w[ 1 2 3 ] }
    @set.add(%w[ 5 6 7 ])
    @set.replace(%w[ 8 9 10 ])
    assert_equal [ 8, 9, 10 ], @set.members
  end
end
