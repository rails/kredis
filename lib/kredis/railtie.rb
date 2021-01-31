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

    initializer "kredis.logger" do
      Kredis.logger = config.kredis.logger || Rails.logger
    end

    initializer "kredis.configurator" do
      Kredis.configurator = Rails.application
    end

    initializer "kredis.attributes" do
      # TODO: Add run_load_hooks to ActiveModel::Model so this runs.
      ActiveSupport.on_load(:active_model) do
        include Kredis::Attributes
      end

      ActiveSupport.on_load(:active_record) do
        include Kredis::Attributes
      end
    end
  end
end
