# frozen_string_literal: true

require "test_helper"

class EnumTest < ActiveSupport::TestCase
  setup { @enum = Kredis.enum "myenum", values: %w[ one two three ], default: "one" }

  test "default" do
    assert_equal "one", @enum.value
  end

  test "default via proc" do
    @enum = Kredis.enum "myenum2", values: %w[ one two three ], default: ->() { "two" }
    assert_equal "two", @enum.value
  end

  test "default can be nil" do
    enum = Kredis.enum "myenum3", values: [ 1, 2, 3 ], default: nil
    assert_nil enum.value
  end

  test "default value has to be valid if not nil" do
    assert_raises Kredis::Types::Enum::InvalidDefault do
      Kredis.enum "myenum4", values: [ 1, 2, 3 ], default: 4
    end
  end

  test "predicates" do
    assert @enum.one?

    @enum.value = "two"
    assert @enum.two?

    assert_not @enum.three?

    @enum.three!
    assert @enum.three?

    assert_not @enum.two?
  end

  test "validated value" do
    assert @enum.one?

    @enum.value = "nonesense"
    assert @enum.one?
  end

  test "reset" do
    @enum.value = "two"
    assert @enum.two?

    @enum.reset
    assert @enum.one?
  end

  test "exists?" do
    enum = Kredis.enum "numbers", values: %w[ one two three ], default: nil
    assert_not enum.exists?

    enum.value = "one"
    assert enum.exists?
  end
end
