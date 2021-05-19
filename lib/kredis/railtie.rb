class Kredis::Railtie < ::Rails::Railtie
  config.kredis = ActiveSupport::OrderedOptions.new

  initializer "kredis.testing" do
    ActiveSupport.on_load(:active_support_test_case) do
      parallelize_setup { |worker| Kredis.namespace = "test-#{worker}" }
      teardown { Kredis.clear_all }
    end
  end

  initializer "kredis.logger" do
    Kredis::LogSubscriber.logger = config.kredis.logger || Rails.logger
  end

  initializer "kredis.configurator" do
    Kredis.configurator = Rails.application
  end

  initializer "kredis.attributes" do
    # No load hook for Active Model, just defer until after initialization.
    config.after_initialize do
      ActiveModel::Model.include Kredis::Attributes if defined?(ActiveModel::Model)
    end

    ActiveSupport.on_load(:active_record) do
      include Kredis::Attributes
    end
  end
end
