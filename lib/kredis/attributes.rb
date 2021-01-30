module Kredis::Attributes
  extend ActiveSupport::Concern

  class_methods do
    def kredis_list(name, config: :shared)
      ivar_symbol = :"@#{name}_kredis_list"

      define_method(name) do
        if instance_variable_defined?(ivar_symbol)
          instance_variable_get(ivar_symbol)
        else
          instance_variable_set(ivar_symbol, Kredis.list(kredis_key_for_attribute(name), config: config))
        end
      end
    end

    def kredis_unique_list(name, limit: nil, config: :shared)
      ivar_symbol = :"@#{name}_kredis_unique_list"

      define_method(name) do
        if instance_variable_defined?(ivar_symbol)
          instance_variable_get(ivar_symbol)
        else
          instance_variable_set(ivar_symbol, Kredis.unique_list(kredis_key_for_attribute(name), limit: limit, config: config))
        end
      end
    end

    def kredis_flag(name, config: :shared)
      ivar_symbol = :"@#{name}_kredis_flag"

      define_method(name) do
        if instance_variable_defined?(ivar_symbol)
          instance_variable_get(ivar_symbol)
        else
          instance_variable_set(ivar_symbol, Kredis.flag(kredis_key_for_attribute(name), config: config))
        end
      end

      define_method("#{name}?") do
        instance_variable_defined?(ivar_symbol) && instance_variable_get(ivar_symbol).marked?
      end
    end

    def kredis_string(name, config: :shared)
      ivar_symbol = :"@#{name}_kredis_string"

      define_method(name) do
        if instance_variable_defined?(ivar_symbol)
          instance_variable_get(ivar_symbol)
        else
          instance_variable_set(ivar_symbol, Kredis.string(kredis_key_for_attribute(name), config: config))
        end
      end
    end

    def kredis_integer(name, config: :shared)
      ivar_symbol = :"@#{name}_kredis_integer"

      define_method(name) do
        if instance_variable_defined?(ivar_symbol)
          instance_variable_get(ivar_symbol)
        else
          instance_variable_set(ivar_symbol, Kredis.integer(kredis_key_for_attribute(name), config: config))
        end
      end
    end
  end

  private
    def kredis_key_for_attribute(name)
      "#{self.class.name.tableize.gsub("/", ":")}:#{id}:#{name}"
    end
end
