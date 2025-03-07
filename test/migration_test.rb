# frozen_string_literal: true

require "test_helper"

class MigrationTest < ActiveSupport::TestCase
  test "migrate_all" do
    3.times { |index| Kredis.proxy("mykey:#{index}").set "hello there #{index}" }

    Kredis::Migration.migrate_all(Kredis.namespaced_key("mykey:*")) { |key| "thykey:#{key.split(":").last}" }

    3.times do |index|
      assert_equal "hello there #{index}", Kredis.proxy("thykey:#{index}").get
    end
  end

  test "migrate" do
    @original_global_namespace, Kredis.global_namespace = Kredis.global_namespace, nil

    old_proxy = Kredis.string "old_proxy"
    old_proxy.set "hello there"

    new_proxy = Kredis.string "new_proxy"
    assert_not new_proxy.assigned?

    Kredis::Migration.migrate from: Kredis.namespaced_key("old_proxy"), to: "new_proxy"
    assert_equal "hello there", new_proxy.value
    assert old_proxy.assigned?, "just copying the data"
  ensure
    Kredis.global_namespace = @original_global_namespace
  end

  test "migrate with blank keys" do
    assert_nothing_raised do
      Kredis::Migration.migrate from: Kredis.namespaced_key("old_key"), to: nil
      Kredis::Migration.migrate from: Kredis.namespaced_key("old_key"), to: ""
    end
  end

  test "migrate with namespace" do
    Kredis.proxy("key").set "x"

    Kredis.namespace = "migrate"

    Kredis::Migration.migrate from: "#{Kredis.global_namespace}:key", to: "key"

    assert_equal "x", Kredis.proxy("key").get
  ensure
    Kredis.namespace = nil
  end

  test "migrate with automatic id extraction" do
    Kredis.proxy("mykey:1").set "hey"

    Kredis::Migration.migrate_all Kredis.namespaced_key("mykey:*") do |key, id|
      assert_equal 1, id
      key
    end
  end

  test "delete_all with pattern" do
    3.times { |index| Kredis.proxy("mykey:#{index}").set "hello there #{index}" }

    Kredis::Migration.delete_all Kredis.namespaced_key("mykey:*")

    3.times { |index| assert_nil Kredis.proxy("mykey:#{index}").get }
  end

  test "delete_all with keys" do
    3.times { |index| Kredis.proxy("mykey:#{index}").set "hello there #{index}" }

    Kredis::Migration.delete_all(*3.times.map { |index| Kredis.namespaced_key("mykey:#{index}") })

    3.times { |index| assert_nil Kredis.proxy("mykey:#{index}").get }
  end
end
