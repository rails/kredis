require "test_helper"
require "active_support/core_ext/integer"

class Person
  include Kredis::Attributes

  kredis_proxy :anything, default: "default"
  kredis_proxy :nothing, key: "something:else"
  kredis_proxy :something, key: ->(p) { "person:#{p.id}:something" }, default: :name
  kredis_proxy :something_with_default_via_lambda, default: ->(p) { p.name.downcase }
  kredis_list :names
  kredis_list :names_with_custom_key_via_lambda, key: ->(p) { "person:#{p.id}:names_customized" }
  kredis_list :names_with_custom_key_via_method, key: :generate_key
  kredis_list :names_with_default_via_lambda, default: ->(p) { ["Random", p.name] }
  kredis_unique_list :skills, limit: 2
  kredis_unique_list :skills_with_default_via_lambda, default: ->(p) { ["Random", "Random", p.name] }
  kredis_flag :special
  kredis_flag :temporary_special, expires_in: 1.second
  kredis_flag :special_with_default_via_lambda, default: ->(p) { p.id == 8 }
  kredis_string :address
  kredis_string :address_with_default_via_lambda, default: ->(p) { p.name }
  kredis_integer :age
  kredis_integer :age_with_default_via_lambda, default: ->(p) { Date.today.year - p.birthdate.year }
  kredis_decimal :salary
  kredis_decimal :salary_with_default_via_lambda, default: ->(p) { p.hourly_wage * 40 * 52 }
  kredis_datetime :last_seen_at
  kredis_datetime :last_seen_at_with_default_via_lambda, default: ->(p) { p.last_login }
  kredis_float :height
  kredis_enum :morning, values: %w[ bright blue black ], default: "bright"
  kredis_slot :attention
  kredis_slots :meetings, available: 3
  kredis_set :vacations
  kredis_json :settings
  kredis_counter :amount
  kredis_counter :expiring_amount, expires_in: 1.second
  kredis_string :temporary_password, expires_in: 1.second
  kredis_hash :high_scores, typed: :integer
  kredis_boolean :onboarded

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
  
  def hourly_wage
    15.26
  end

  def last_login
    Time.new(2002, 10, 31, 2, 2, 2, "+02:00")
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
    assert_equal "default", @person.anything.get
    @person.anything.set "something"
    assert_equal "something", @person.anything.get
  end

  test "proxy with custom string key" do
    @person.nothing.set "everything"
    assert_equal "everything", Kredis.redis.get("something:else")
  end

  test "proxy with custom proc key" do
    assert_equal "Jason", @person.something.get
    @person.something.set "everything"
    assert_equal "everything", Kredis.redis.get("person:8:something")
  end

  test "proxy with default value" do
    assert_equal "jason", @person.something_with_default_via_lambda.get
    assert_equal "jason", Kredis.redis.get("people:8:something_with_default_via_lambda")
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

  test "flag" do
    assert_not @person.special?

    @person.special.mark
    assert @person.special?

    @person.special.remove
    assert_not @person.special?
  end

  test "flag with default proc value" do
    assert @person.special_with_default_via_lambda?
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
    assert_equal "31740.8", @person.salary_with_default_via_lambda.to_s
  end

  test "float" do
    @person.height.value = 1.85
    assert_equal 1.85, @person.height.value
    assert_equal "1.85", @person.height.to_s
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

  test "json" do
    @person.settings.value = { "color" => "red", "count" => 2 }
    assert_equal({ "color" => "red", "count" => 2 }, @person.settings.value)
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

  test "hash" do
    @person.high_scores.update(space_invaders: 100, pong: 42)
    assert_equal({ "space_invaders" => 100, "pong" => 42 }, @person.high_scores.to_h)
    assert_equal([ "space_invaders", "pong" ], @person.high_scores.keys)
    assert_equal([ 100, 42 ], @person.high_scores.values)
  end

  test "boolean" do
    @person.onboarded.value = true
    assert @person.onboarded.value

    @person.onboarded.value = false
    refute @person.onboarded.value
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
end
