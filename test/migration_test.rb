require "test_helper"

class MigrationTest < ActiveSupport::TestCase
  setup do
    @proxy = Kredis.string "new_proxy"
  end

  test "migrate_all" do
    3.times { |index| Kredis.proxy("mykey:#{index}").set "hello there #{index}" }

    Kredis::Migration.migrate_all("mykey:*") { |key| key.gsub("mykey", "thykey") }

    3.times do |index|
      assert_equal "hello there #{index}", Kredis.proxy("thykey:#{index}").get
    end
  end

  test "migrate" do
    old_proxy = Kredis.string "old_proxy"
    old_proxy.set "hello there"
    assert_not @proxy.assigned?

    Kredis::Migration.migrate from: "old_proxy", to: @proxy.key
    assert_equal "hello there", @proxy.value
    assert old_proxy.assigned?, "just copying the data"
  end

  test "migrate with blank keys" do
    assert_nothing_raised do
      Kredis::Migration.migrate from: "old_key", to: nil
      Kredis::Migration.migrate from: "old_key", to: ""
    end
  end

  test "migrate with namespace" do
    Kredis.proxy("key").set "x"

    Kredis.namespace = "migrate"

    Kredis::Migration.migrate from: "key", to: "key"

    assert_equal "x", Kredis.proxy("key").get
  ensure
    Kredis.namespace = nil
  end

  test "migrate with automatic id extraction" do
    Kredis.proxy("mykey:1").set "hey"

    Kredis::Migration.migrate_all "mykey:*" do |key, id|
      assert_equal 1, id
      key
    end
  end

  test "delete_all" do
    3.times { |index| Kredis.proxy("mykey:#{index}").set "hello there #{index}" }

    Kredis::Migration.delete_all "mykey:*"

    3.times { |index| assert_nil Kredis.proxy("mykey:#{index}").get }
  end
end
