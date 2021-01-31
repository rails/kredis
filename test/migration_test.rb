require "test_helper"
require "kredis/migration"

class MigrationTest < ActiveSupport::TestCase
  setup do
    @proxy = Kredis.string "new_proxy"
    @migration = Kredis::Migration.configured_for(:shared)
  end

  test "migrate_all" do
    3.times { |index| Kredis.proxy("mykey:#{index}").set "hello there #{index}" }

    @migration.migrate_all("mykey:*") { |key| key.gsub("mykey", "thykey") }

    3.times do |index|
      assert_equal "hello there #{index}", Kredis.proxy("thykey:#{index}").get
    end
  end

  test "migrate" do
    old_proxy = Kredis.string "old_proxy"
    old_proxy.set "hello there"
    assert_not @proxy.assigned?

    @migration.migrate from: "old_proxy", to: @proxy.key
    assert_equal "hello there", @proxy.value
    assert old_proxy.assigned?, "just copying the data"
  end

  test "migrate with namespace" do
    Kredis.proxy("key").set "x"

    Kredis.namespace = "migrate"

    @migration.migrate from: "key", to: "key"

    assert_equal "x", Kredis.proxy("key").get
  ensure
    Kredis.namespace = nil
  end
end
