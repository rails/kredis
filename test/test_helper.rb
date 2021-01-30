require "bundler/setup"
require "rails"
require "rails/test_help"
require "active_support/testing/autorun"

require "kredis"

Kredis.configurator = Class.new { def config_for(name) {} end }.new

class ActiveSupport::TestCase
  teardown { Kredis.clear_all }
end
