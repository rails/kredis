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
      Kredis.logger = Rails.logger
    end

    initializer "kredis.configurator" do
      Kredis.configurator = Rails.application
    end

    initializer "kredis.attributes" do
      ActiveSupport.on_load(:active_model) do
        ActiveModel::Base.send :include, Kredis::Attributes
      end

      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, Kredis::Attributes
      end
    end
  end
end
