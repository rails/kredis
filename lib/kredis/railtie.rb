# frozen_string_literal: true

class Kredis::Railtie < ::Rails::Railtie
  config.kredis = ActiveSupport::OrderedOptions.new

  initializer "kredis.testing" do
    ActiveSupport.on_load(:active_support_test_case) do
      $kredis_parallel_worker = nil
      parallelize_setup { |worker| $kredis_parallel_worker = worker }

      setup do
        @original_namespace = Kredis.namespace
        Kredis.namespace = [ @original_namespace, :test, $kredis_parallel_worker ].compact.join("-")
      end

      teardown do
        Kredis.clear_all
        Kredis.namespace = @original_namespace
      end
    end
  end

  initializer "kredis.logger" do
    Kredis::LogSubscriber.logger = config.kredis.logger || Rails.logger
  end

  initializer "kredis.configuration" do
    Kredis::Connections.connector = config.kredis.connector || ->(config) { Redis.new(config) }
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

  rake_tasks do
    path = File.expand_path("..", __dir__)
    Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
  end
end
