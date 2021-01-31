require "test_helper"

class Person
  include Kredis::Attributes

  kredis_proxy :anything
  kredis_proxy :nothing, key: "something:else"
  kredis_proxy :something, key: ->(p) { "person:#{p.id}:something" }
  kredis_list :names
  kredis_list :names_with_custom_key, key: ->(p) { "person:#{p.id}:names_customized" }
  kredis_unique_list :skills, limit: 2
  kredis_flag :special
  kredis_string :address
  kredis_integer :age
  kredis_enum :morning, values: %w[ bright blue black ], default: "bright"
  kredis_slot :attention
  kredis_slots :meetings, available: 3
  kredis_set :vacations

  def self.name
    "Person"
  end

  def id
    8
  end
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
    @person.names_with_custom_key.append(%w[ david kasper ])
    assert_equal %w[ david kasper ], Kredis.redis.lrange("person:8:names_customized", 0, -1)
  end

  test "unique list" do
    @person.skills.prepend(%w[ trolling photography ])
    @person.skills.prepend("racing")
    @person.skills.prepend("racing")
    assert_equal %w[ racing photography ], @person.skills.elements
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

    @person.address.assign = "Copenhagen"
    assert @person.address.assigned?
    assert_equal "Copenhagen", @person.address.to_s

    @person.address.clear
    assert_not @person.address.assigned?
  end

  test "integer" do
    @person.age.assign = 41
    assert_equal 41, @person.age.value
    assert_equal "41", @person.age.to_s
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
    assert_equal [ "paris" ], @person.vacations.elements

    @person.vacations << "berlin"
    assert_equal %w[ paris berlin ].sort, @person.vacations.elements.sort

    assert @person.vacations.includes?("berlin")
    assert_equal 2, @person.vacations.size

    @person.vacations.remove("berlin")
    assert_equal "paris", @person.vacations.take
  end
end
