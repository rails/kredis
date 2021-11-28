require "test_helper"

class AttributesCallbacksTest < ActiveSupport::TestCase
  class Person
    include Kredis::Attributes

    def self.name
      "Person"
    end

    def id
      8
    end
  end

  test "list with after_change callback" do
    assert_callback_executed_for :kredis_list, :proc,   ->(type) { type.append %w[ david kasper ] }
    assert_callback_executed_for :kredis_list, :method, ->(type) { type << %w[ david kasper ] }
  end

  test "flag with after_change callback" do
    assert_callback_executed_for :kredis_flag, :proc,   ->(type) { type.mark }
    assert_callback_executed_for :kredis_flag, :method, ->(type) { type.mark }
  end

  test "string with after_change callback" do
    assert_callback_executed_for :kredis_string, :proc,   ->(type) { type.value = "Copenhagen" }
    assert_callback_executed_for :kredis_string, :method, ->(type) { type.value = "Copenhagen" }
  end

  test "slot with after_change callback" do
    assert_callback_executed_for :kredis_slot, :proc,   ->(type) { type.reserve }
    assert_callback_executed_for :kredis_slot, :method, ->(type) { type.reserve }
  end

  test "enum with after_change callback" do
    assert_callback_executed_for :kredis_enum, :proc,   ->(type) { type.value = "blue" }, values: %w[ bright blue black ], default: "bright"
    assert_callback_executed_for :kredis_enum, :method, ->(type) { type.value = "blue" }, values: %w[ bright blue black ], default: "bright"
  end

  test "set with after_change callback" do
    assert_callback_executed_for :kredis_set, :proc,   ->(type) { type.add "paris" }
    assert_callback_executed_for :kredis_set, :method, ->(type) { type << "paris" }
  end

  test "json with after_change callback" do
    assert_callback_executed_for :kredis_json, :proc,   ->(type) { type.value = { "color" => "red", "count" => 2 } }
    assert_callback_executed_for :kredis_json, :method, ->(type) { type.value = { "color" => "red", "count" => 2 } }
  end

  test "counter with after_change callback" do
    assert_callback_executed_for :kredis_counter, :proc,   ->(type) { type.increment }
    assert_callback_executed_for :kredis_counter, :method, ->(type) { type.increment }
  end

  test "hash with after_change callback" do
    assert_callback_executed_for :kredis_hash, :proc,   ->(type) { type.update space_invaders: 100, pong: 42 }
    assert_callback_executed_for :kredis_hash, :method, ->(type) { type.update space_invaders: 100, pong: 42 }

    assert_callback_executed_for :kredis_hash, :proc,   ->(type) { type[:space_invaders] = 0 }
    assert_callback_executed_for :kredis_hash, :method, ->(type) { type[:space_invaders] = 0 }

    assert_callback_executed_for :kredis_hash, :proc, ->(type) { type.delete "key" }

    assert_callback_executed_for :kredis_hash, :method, ->(type) { type.remove }
  end

  private
    def assert_callback_executed_for(attribute_type, kind, executor, **options)
      called = false

      new_person = Class.new(Person) do
        send attribute_type, :type, **options, after_change: kind == :proc ? proc { called = true } : :changed
        define_method(:changed) { called = true }
      end

      executor.call(new_person.new.type)
      assert called
    end
end
