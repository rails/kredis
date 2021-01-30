require "rails/railtie"

module Kredis
  class Railtie < ::Rails::Railtie
    config.kredis = ActiveSupport::OrderedOptions.new
    config.eager_load_namespaces << Kredis

    initializer "kredis.testing" do
      ActiveSupport.on_load(:active_support_test_case) do
        parallelize_setup    { |worker| Kredis.namespace = "test-#{worker}" }
        parallelize_teardown { Kredis.clear_all }
      end
    end
  end
end
