require "test_helper"

class JsonTest < ActiveSupport::TestCase
  setup { @json = Kredis.json "myjson" }

  test "dump and load" do
    @json.value = { "a" => "1", "c" => 2 }
    assert_equal({ "a" => "1", "c" => 2 }, @json.value)
  end
end
