require "test_helper"

class CallbacksTest < ActiveSupport::TestCase
  test "list with after_change proc callback" do
    @callback_check = nil
    names = Kredis.with_callback :list, "names", after_change: ->(list) { @callback_check = list.elements }
    names.append %w[ david kasper ]

    assert_equal %w[ david kasper ], @callback_check
  end

  test "flag with after_change proc callback" do
    @callback_check = nil
    special = Kredis.with_callback :flag, "special", after_change: ->(flag) { @callback_check = flag.marked? }
    special.mark

    assert @callback_check
  end

  test "string with after_change proc callback" do
    @callback_check = nil
    address = Kredis.with_callback :string, "address", after_change: ->(scalar) { @callback_check = scalar.value }
    address.value = "Copenhagen"

    assert_equal "Copenhagen", @callback_check
  end

  test "slot with after_change proc callback" do
    @callback_check = true
    attention = Kredis.with_callback :slot, "attention", after_change: ->(slot) { @callback_check = slot.available? }
    attention.reserve

    refute @callback_check
  end

  test "enum with after_change proc callback" do
    @callback_check = nil
    morning = Kredis.with_callback :enum, "morning", values: %w[ bright blue black ], default: "bright", after_change: ->(enum) { @callback_check = enum.value }
    morning.value = "blue"

    assert_equal "blue", @callback_check
  end

  test "set with after_change proc callback" do
    @callback_check = nil
    vacations = Kredis.with_callback :set, "vacations", after_change: ->(set) { @callback_check = set.members }
    vacations.add "paris"

    assert_equal ["paris"], @callback_check
  end

  test "hash with after_change proc callback" do
    @callback_check = nil
    high_scores = Kredis.with_callback :hash, "high_scores", typed: :integer, after_change: ->(hash) { @callback_check = hash.entries }
    high_scores.update(space_invaders: 100, pong: 42)

    assert_equal({ "space_invaders" => 100, "pong" => 42 }, @callback_check)
  end

  test "json with after_change proc callback" do
    @callback_check = nil
    settings = Kredis.with_callback :json, "settings", after_change: ->(json) { @callback_check = settings.value }
    settings.value = { "color" => "red", "count" => 2 }

    assert_equal ({ "color" => "red", "count" => 2 }), @callback_check
  end

  test "counter with after_change proc callback" do
    @callback_check = nil
    amount = Kredis.with_callback :counter, "amount", after_change: ->(counter) { @callback_check = counter.value }
    amount.increment

    assert_equal 1, @callback_check
  end
end
