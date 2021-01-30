require "test_helper"

class Person
  include Kredis::Attributes

  kredis_proxy :anything
  kredis_list :names
  kredis_unique_list :skills, limit: 2
  kredis_flag :special
  kredis_string :address
  kredis_integer :age

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

  test "list" do
    @person.names.append(%w[ david kasper ])
    assert_equal %w[ david kasper ], @person.names.elements
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
end
