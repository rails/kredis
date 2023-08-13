# frozen_string_literal: true

require "test_helper"

class Identity
  def id
    1
  end
end

class Person
  include Kredis::Attributes

  kredis_list :names_with_scope, scope: :identity
  kredis_list :names_with_scope_and_key, scope: :identity, key: ->(person) { "custom_key_#{person.example_method}" }

  def identity
    Identity.new
  end

  def example_method
    "example"
  end
end

class Family
  include Kredis::Attributes

  kredis_list :members
  kredis_list :pets, key: "pets"

  def id
    1
  end
end


class ScopeTest < ActiveSupport::TestCase
  setup { @person = Person.new }

  test "key is scoped" do
    assert_equal @person.names_with_scope.key, "identities:1:people:names_with_scope"
  end

  test "key is scoped and has custom key component" do
    assert_equal @person.names_with_scope_and_key.key, "identities:1:custom_key_example"
  end

  test "custom key" do
    assert_equal Family.new.pets.key, "pets"
  end

  test "key without scope" do
    assert_equal Family.new.members.key, "families:1:members"
  end
end
