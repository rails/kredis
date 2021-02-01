require "bundler/setup"
require "rails"
require "rails/test_help"
require "active_support/testing/autorun"
require "byebug"

require "kredis"

Kredis.configurator = Class.new { def config_for(name) {} end }.new

Kredis.logger = Logger.new(STDOUT) if ENV["VERBOSE"]

class ActiveSupport::TestCase
  teardown { Kredis.clear_all }
end
