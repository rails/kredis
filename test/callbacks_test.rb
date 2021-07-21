require "test_helper"

class Person
  include Kredis::Attributes

  kredis_list :names_with_proc_callback, after_change: ->(p) { p.callback_flag = true }
  kredis_list :names_with_method_callback, after_change: :changed
  kredis_flag :special_with_proc_callback, after_change: ->(p) { p.callback_flag = true }
  kredis_flag :special_with_method_callback, after_change: :changed
  kredis_string :address_with_proc_callback, after_change: ->(p) { p.callback_flag = true }
  kredis_string :address_with_method_callback, after_change: :changed
  kredis_enum :morning_with_proc_callback, values: %w[ bright blue black ], default: "bright", after_change: ->(p) { p.callback_flag = true }
  kredis_enum :morning_with_method_callback, values: %w[ bright blue black ], default: "bright", after_change: :changed
  kredis_slot :attention_with_proc_callback, after_change: ->(p) { p.callback_flag = true }
  kredis_slot :attention_with_method_callback, after_change: :changed
  kredis_set :vacations_with_proc_callback, after_change: ->(p) { p.callback_flag = true }
  kredis_set :vacations_with_method_callback, after_change: :changed
  kredis_json :settings_with_proc_callback, after_change: ->(p) { p.callback_flag = true }
  kredis_json :settings_with_method_callback, after_change: :changed
  kredis_counter :amount_with_proc_callback, after_change: ->(p) { p.callback_flag = true }
  kredis_counter :amount_with_method_callback, after_change: :changed
  kredis_hash :high_scores_with_proc_callback, after_change: ->(p) { p.callback_flag = true }
  kredis_hash :high_scores_with_method_callback, after_change: :changed

  attr_accessor :callback_flag

  def initialize
    @callback_flag = false
  end

  def self.name
    "Person"
  end

  def id
    8
  end

  def changed
    @callback_flag = true
  end
end

class CallbacksTest < ActiveSupport::TestCase
  setup do
    @person = Person.new

    refute @person.callback_flag
  end

  test "list with after_change proc callback" do
    @person.names_with_proc_callback.append %w[ david kasper ]

    assert @person.callback_flag
  end

  test "list with after_change method callback" do
    @person.names_with_method_callback.append %w[ david kasper ]

    assert @person.callback_flag
  end

  test "flag with after_change proc callback" do
    @person.special_with_proc_callback.mark

    assert @person.callback_flag
  end

  test "flag with after_change method callback" do
    @person.special_with_method_callback.mark

    assert @person.callback_flag
  end

  test "string with after_change proc callback" do
    @person.address_with_proc_callback.value = "Copenhagen"

    assert @person.callback_flag
  end

  test "string with after_change method callback" do
    @person.address_with_proc_callback.value = "Copenhagen"

    assert @person.callback_flag
  end

  test "slot with after_change proc callback" do
    @person.attention_with_proc_callback.reserve

    assert @person.callback_flag
  end

  test "slot with after_change method callback" do
    @person.attention_with_method_callback.reserve

    assert @person.callback_flag
  end

  test "enum with after_change proc callback" do
    @person.morning_with_proc_callback.value = "blue"

    assert @person.callback_flag
  end

  test "enum with after_change method callback" do
    @person.morning_with_method_callback.value = "blue"

    assert @person.callback_flag
  end

  test "set with after_change proc callback" do
    @person.vacations_with_proc_callback.add "paris"

    assert @person.callback_flag
  end

  test "set with after_change method callback" do
    @person.vacations_with_method_callback.add "paris"

    assert @person.callback_flag
  end

  test "json with after_change proc callback" do
    @person.settings_with_proc_callback.value = { "color" => "red", "count" => 2 }

    assert @person.callback_flag
  end

  test "json with after_change method callback" do
    @person.settings_with_method_callback.value = { "color" => "red", "count" => 2 }

    assert @person.callback_flag
  end

  test "counter with after_change proc callback" do
    @person.amount_with_proc_callback.increment

    assert @person.callback_flag
  end

  test "counter with after_change method callback" do
    @person.amount_with_method_callback.increment

    assert @person.callback_flag
  end

  test "hash with after_change proc callback" do
    @person.high_scores_with_proc_callback.set(space_invaders: 100, pong: 42) 

    assert @person.callback_flag
  end

  test "hash with after_change method callback" do
    @person.high_scores_with_method_callback.set(space_invaders: 100, pong: 42) 

    assert @person.callback_flag
  end
end
