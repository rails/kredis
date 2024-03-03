# frozen_string_literal: true

require "test_helper"
require "active_support/core_ext/integer"

class Person
  include Kredis::Attributes

  kredis_proxy :anything
  kredis_proxy :nothing, key: "something:else"
  kredis_proxy :something, key: ->(p) { "person:#{p.id}:something" }
  kredis_list :names
  kredis_list :names_with_custom_key_via_lambda, key: ->(p) { "person:#{p.id}:names_customized" }
  kredis_list :names_with_custom_key_via_method, key: :generate_key
  kredis_list :names_with_default_via_lambda, default: ->(p) { [ "Random", p.name ] }
  kredis_list :names_with_ttl, expires_in: 1.second
  kredis_unique_list :skills, limit: 2
  kredis_unique_list :skills_with_default_via_lambda, default: ->(p) { [ "Random", "Random", p.name ] }
  kredis_unique_list :skills_with_ttl, expires_in: 1.second
  kredis_ordered_set :reading_list, limit: 2
  kredis_flag :special
  kredis_flag :temporary_special, expires_in: 1.second
  kredis_string :address
  kredis_string :address_with_default_via_lambda, default: ->(p) { p.name }
  kredis_integer :age
  kredis_integer :age_with_default_via_lambda, default: ->(p) { Date.today.year - p.birthdate.year }
  kredis_decimal :salary
  kredis_decimal :salary_with_default_via_lambda, default: ->(p) { p.hourly_wage * 40 * 52 }
  kredis_datetime :last_seen_at
  kredis_datetime :last_seen_at_with_default_via_lambda, default: ->(p) { p.last_login }
  kredis_float :height
  kredis_float :height_with_default_via_lambda, default: ->(p) { JSON.parse(p.anthropometry)["height"] }
  kredis_enum :morning, values: %w[ bright blue black ], default: "bright"
  kredis_enum :eye_color_with_default_via_lambda, values: %w[ hazel blue brown ], default: ->(p) { { ha: "hazel", bl: "blue", br: "brown" }[p.eye_color.to_sym] }
  kredis_slot :attention
  kredis_slots :meetings, available: 3
  kredis_set :vacations
  kredis_set :vacations_with_default_via_lambda, default: ->(p) { JSON.parse(p.vacation_destinations).map { |location| location["city"] } }
  kredis_set :vacations_with_ttl, expires_in: 1.second
  kredis_json :settings
  kredis_json :settings_with_default_via_lambda, default: ->(p) { JSON.parse(p.anthropometry).merge(eye_color: p.eye_color) }
  kredis_counter :amount
  kredis_counter :amount_with_default_via_lambda, default: ->(p) { Date.today.year - p.birthdate.year }
  kredis_counter :expiring_amount, expires_in: 1.second
  kredis_string :temporary_password, expires_in: 1.second
  kredis_hash :high_scores, typed: :integer
  kredis_hash :high_scores_with_default_via_lambda, typed: :integer, default: ->(p) { { high_score: JSON.parse(p.scores).max } }
  kredis_boolean :onboarded
  kredis_boolean :adult_with_default_via_lambda, default: ->(p) { Date.today.year - p.birthdate.year >= 18 }
  kredis_limiter :update_limit, limit: 3, expires_in: 1.second

  def self.name
    "Person"
  end

  def id
    8
  end

  def name
    "Jason"
  end

  def birthdate
    Date.today - 25.years
  end

  def anthropometry
    { height: 73.2, weight: 182.4 }.to_json
  end

  def eye_color
    "ha"
  end

  def scores
    [ 10, 28, 2, 7 ].to_json
  end

  def hourly_wage
    15.26
  end

  def last_login
    Time.new(2002, 10, 31, 2, 2, 2, "+02:00")
  end

  def vacation_destinations
    [
      { city: "Paris", region: "Île-de-France", country: "FR" },
      { city: "Paris", region: "Texas", country: "US" }
    ].to_json
  end

  def update!
    if update_limit.exceeded?
      raise "Limiter exceeded"
    else
      update_limit.poke
    end
  end

  private
    def generate_key
      "some-generated-key"
    end
end

class MissingIdPerson
  include Kredis::Attributes

  kredis_proxy :anything
  kredis_proxy :nothing, key: "something:else"
end

class AttributesTest < ActiveSupport::TestCase
  setup { @person = Person.new }

  test "proxy" do
    @person.anything.set "something"
    assert_equal "something", @person.anything.get
  end

  test "proxy with custom string key" do
    @person.nothing.set "everything"
    assert_equal "everything", Kredis.redis.get("something:else")
  end

  test "proxy with custom proc key" do
    @person.something.set "everything"
    assert_equal "everything", Kredis.redis.get("person:8:something")
  end

  test "list" do
    @person.names.append(%w[ david kasper ])
    assert_equal %w[ david kasper ], @person.names.elements
  end

  test "list with custom proc key" do
    @person.names_with_custom_key_via_lambda.append(%w[ david kasper ])
    assert_equal %w[ david kasper ], Kredis.redis.lrange("person:8:names_customized", 0, -1)
  end

  test "list with custom method key" do
    @person.names_with_custom_key_via_method.append(%w[ david kasper ])
    assert_equal %w[ david kasper ], Kredis.redis.lrange("some-generated-key", 0, -1)
  end

  test "list with default proc value" do
    assert_equal %w[ Random Jason ], @person.names_with_default_via_lambda.elements
    assert_equal %w[ Random Jason ], Kredis.redis.lrange("people:8:names_with_default_via_lambda", 0, -1)
  end

  test "list with ttl" do
    @person.names_with_ttl.append(%w[ david kasper ])
    assert_equal %w[ david kasper ], @person.names_with_ttl.elements

    sleep 1.1
    assert_equal [], @person.names_with_ttl.elements
  end

  test "unique list" do
    @person.skills.prepend(%w[ trolling photography ])
    @person.skills.prepend("racing")
    @person.skills.prepend("racing")
    assert_equal %w[ racing photography ], @person.skills.elements
  end

  test "unique list with default proc value" do
    assert_equal %w[ Random Jason ], @person.skills_with_default_via_lambda.elements
    assert_equal %w[ Random Jason ], Kredis.redis.lrange("people:8:skills_with_default_via_lambda", 0, -1)
  end

  test "unique list with ttl" do
    @person.skills_with_ttl.prepend(%w[ trolling photography ])
    assert_equal %w[ trolling photography ].to_set, @person.skills_with_ttl.elements.to_set

    sleep 1.1
    assert_equal [], @person.skills_with_ttl.elements
  end

  test "ordered set" do
    @person.reading_list.prepend(%w[ rework shapeup remote ])
    assert_equal %w[ remote shapeup ], @person.reading_list.elements
  end

  test "flag" do
    assert_not @person.special?

    @person.special.mark
    assert @person.special?

    @person.special.remove
    assert_not @person.special?
  end

  test "string" do
    assert_not @person.address.assigned?

    @person.address.value = "Copenhagen"
    assert @person.address.assigned?
    assert_equal "Copenhagen", @person.address.to_s

    @person.address.clear
    assert_not @person.address.assigned?
  end

  test "string with default proc value" do
    assert_equal "Jason", @person.address_with_default_via_lambda.to_s

    @person.address.clear
    assert_not @person.address.assigned?
  end

  test "integer" do
    @person.age.value = 41
    assert_equal 41, @person.age.value
    assert_equal "41", @person.age.to_s
  end

  test "integer with default proc value" do
    assert_equal 25, @person.age_with_default_via_lambda.value
    assert_equal "25", @person.age_with_default_via_lambda.to_s
  end

  test "decimal" do
    @person.salary.value = 10000.07
    assert_equal 10000.07, @person.salary.value
    assert_equal "0.1000007e5", @person.salary.to_s
  end

  test "decimal with default proc value" do
    assert_equal 31_740.80.to_d, @person.salary_with_default_via_lambda.value
    assert_equal "0.317408e5", @person.salary_with_default_via_lambda.to_s
  end

  test "float" do
    @person.height.value = 1.85
    assert_equal 1.85, @person.height.value
    assert_equal "1.85", @person.height.to_s
  end

  test "float with default proc value" do
    assert_not_equal 73.2, Kredis.redis.get("people:8:height_with_default_via_lambda")
    assert_equal 73.2, @person.height_with_default_via_lambda.value
    assert_equal "73.2", @person.height_with_default_via_lambda.to_s
  end

  test "datetime with default proc value" do
    freeze_time
    @person.last_seen_at.value = Time.now
    assert_equal Time.now, @person.last_seen_at.value
  end

  test "datetime" do
    assert_equal Time.new(2002, 10, 31, 2, 2, 2, "+02:00"), @person.last_seen_at_with_default_via_lambda.value
  end

  test "slot" do
    assert @person.attention.reserve
    assert_not @person.attention.available?
    assert_not @person.attention.reserve

    @person.attention.release
    assert @person.attention.available?

    used_attention = false

    @person.attention.reserve do
      used_attention = true
    end

    assert used_attention

    @person.attention.reserve

    assert_equal "did not run", (@person.attention.reserve { "ran!" } || "did not run")
  end

  test "slots" do
    assert @person.meetings.reserve
    assert @person.meetings.available?

    assert @person.meetings.reserve
    assert @person.meetings.reserve
    assert_not @person.meetings.available?
    assert_not @person.meetings.reserve

    @person.meetings.release
    assert @person.meetings.available?

    used_meeting = false

    @person.meetings.reserve do
      used_meeting = true
    end

    assert used_meeting

    @person.meetings.reset

    3.times { @person.meetings.reserve }
    assert_equal "did not run", (@person.meetings.reserve { "ran!" } || "did not run")
  end

  test "enum" do
    assert @person.morning.bright?

    assert @person.morning.value = "blue"
    assert @person.morning.blue?

    assert_not @person.morning.black?

    assert @person.morning.value = "nonsense"
    assert @person.morning.blue?

    @person.morning.reset
    assert @person.morning.bright?
  end

  test "enum with default proc value" do
    assert @person.eye_color_with_default_via_lambda.hazel?
  end


  test "set" do
    @person.vacations.add "paris"
    @person.vacations.add "paris"
    assert_equal [ "paris" ], @person.vacations.to_a

    @person.vacations << "berlin"
    assert_equal %w[ paris berlin ].sort, @person.vacations.members.sort

    assert @person.vacations.include?("berlin")
    assert_equal 2, @person.vacations.size

    @person.vacations.remove("berlin")
    assert_equal "paris", @person.vacations.take
  end

  test "set with default proc value" do
    assert_equal [ "Paris" ], @person.vacations_with_default_via_lambda.members
    assert_equal [ "Paris" ], Kredis.redis.smembers("people:8:vacations_with_default_via_lambda")
  end

  test "set with ttl" do
    @person.vacations_with_ttl.add "paris"
    assert_equal [ "paris" ], @person.vacations_with_ttl.members

    sleep 1.1
    assert_equal [], @person.vacations_with_ttl.members
  end

  test "json" do
    @person.settings.value = { "color" => "red", "count" => 2 }
    assert_equal({ "color" => "red", "count" => 2 }, @person.settings.value)
  end

  test "json with default proc value" do
    expect = { "height" => 73.2, "weight" => 182.4, "eye_color" => "ha" }
    assert_equal expect, @person.settings_with_default_via_lambda.value
    assert_equal expect.to_json, Kredis.redis.get("people:8:settings_with_default_via_lambda")
  end


  test "counter" do
    @person.amount.increment
    assert_equal 1, @person.amount.value
    @person.amount.decrement
    assert_equal 0, @person.amount.value
  end

  test "counter with expires_at" do
    @person.expiring_amount.increment
    assert_changes "@person.expiring_amount.value", from: 1, to: 0 do
      sleep 1.1.seconds
    end
  end

  test "counter with default proc value" do
    @person.amount_with_default_via_lambda.increment
    assert_equal 26, @person.amount_with_default_via_lambda.value
    @person.amount_with_default_via_lambda.decrement
    assert_equal 25, @person.amount_with_default_via_lambda.value
  end

  test "hash" do
    @person.high_scores.update(space_invaders: 100, pong: 42)
    assert_equal({ "space_invaders" => 100, "pong" => 42 }, @person.high_scores.to_h)
    assert_equal([ "space_invaders", "pong" ], @person.high_scores.keys)
    assert_equal([ 100, 42 ], @person.high_scores.values)
  end

  test "hash with default proc value" do
    assert_equal({ "high_score" => 28 }, @person.high_scores_with_default_via_lambda.to_h)
  end

  test "boolean" do
    @person.onboarded.value = true
    assert @person.onboarded.value

    @person.onboarded.value = false
    assert_not @person.onboarded.value
  end

  test "boolean with default proc value" do
    assert @person.adult_with_default_via_lambda.value
  end

  test "missing id to constrain key" do
    assert_raise NotImplementedError do
      MissingIdPerson.new.anything
    end

    assert_nil MissingIdPerson.new.nothing.get

    suddenly_implemented_person = MissingIdPerson.new
    def suddenly_implemented_person.id; 8; end

    assert_nil suddenly_implemented_person.anything.get
  end

  test "expiring scalars" do
    @person.temporary_password.value = "assigned"
    assert_changes "@person.temporary_password.value", from: "assigned", to: nil do
      sleep 1.1.seconds
    end
  end

  test "expiring flag" do
    @person.temporary_special.mark
    assert_changes "@person.temporary_special.marked?", from: true, to: false do
      sleep 1.1.seconds
    end
  end

  test "expiring flag with force" do
    assert @person.temporary_special.mark

    sleep 0.5.seconds
    assert_not @person.temporary_special.mark(force: false)

    assert_changes "@person.temporary_special.marked?", from: true, to: false do
      sleep 0.6.seconds
    end
  end

  test "limiter exceeded" do
    3.times { @person.update! }
    assert_raises { @person.update! }
  end

  test "expiring limiter" do
    3.times { @person.update! }
    sleep 1.1
    assert_nothing_raised { 3.times { @person.update! } }
  end
end
