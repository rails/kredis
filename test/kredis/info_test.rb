# frozen_string_literal: true

require "test_helper"
require "yaml"

class InfoTest < ActiveSupport::TestCase
  test "version" do
    assert Kredis.redis_version >= Gem::Version.new("4.0.0")
  end
end
