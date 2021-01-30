require "test_helper"

class Person
  include Kredis::Attributes

  kredis_list :names
  kredis_unique_list :skills, limit: 2

  def self.name
    "Person"
  end

  def id
    8
  end
end

class AttributesTest < ActiveSupport::TestCase
  setup { @person = Person.new }

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
end
