# frozen_string_literal: true

require "test_helper"

class ScopeTest < ActiveSupport::TestCase
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
    kredis_list :members_with_nil_scope, scope: ->(person) { nil }

    def id
      1
    end
  end


  setup do
    @person = Person.new
    @family = Family.new
  end

  test "key is scoped" do
    assert_equal @person.names_with_scope.key, "scope_test:identities:1:scope_test:people:names_with_scope"
  end

  test "key is scoped and has custom key component" do
    assert_equal @person.names_with_scope_and_key.key, "scope_test:identities:1:custom_key_example"
  end

  test "scope is nil and key is generated normally" do
    assert_equal @family.members_with_nil_scope.key, "scope_test:families:1:members_with_nil_scope"
  end

  test "custom key" do
    assert_equal @family.pets.key, "pets"
  end

  test "key without scope" do
    assert_equal @family.members.key, "scope_test:families:1:members"
  end
end
