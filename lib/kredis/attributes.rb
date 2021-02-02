module Kredis::Attributes
  extend ActiveSupport::Concern

  class_methods do
    def kredis_proxy(name, key: nil, config: :shared)
      kredis_connection_with __method__, name, key, config: config
    end

    def kredis_string(name, key: nil, config: :shared)
      kredis_connection_with __method__, name, key, config: config
    end

    def kredis_integer(name, key: nil, config: :shared)
      kredis_connection_with __method__, name, key, config: config
    end

    def kredis_datetime(name, key: nil, config: :shared)
      kredis_connection_with __method__, name, key, config: config
    end

    def kredis_flag(name, key: nil, config: :shared)
      kredis_connection_with __method__, name, key, config: config

      define_method("#{name}?") do
        send(name).marked?
      end
    end

    def kredis_enum(name, key: nil, values:, default:, config: :shared)
      kredis_connection_with __method__, name, key, values: values, default: default, config: config
    end

    def kredis_json(name, key: nil, config: :shared)
      kredis_connection_with __method__, name, key, config: config
    end

    def kredis_list(name, key: nil, typed: :string, config: :shared)
      kredis_connection_with __method__, name, key, typed: typed, config: config
    end

    def kredis_unique_list(name, limit: nil, key: nil, typed: :string, config: :shared)
      kredis_connection_with __method__, name, key, limit: limit, typed: typed, config: config
    end

    def kredis_set(name, key: nil, typed: :string, config: :shared)
      kredis_connection_with __method__, name, key, typed: typed, config: config
    end

    def kredis_slot(name, key: nil, config: :shared)
      kredis_connection_with __method__, name, key, config: config
    end

    def kredis_slots(name, available:, key: nil, config: :shared)
      kredis_connection_with __method__, name, key, available: available, config: config
    end

    private
      def kredis_connection_with(method, name, key, **options)
        ivar_symbol = :"@#{name}_#{method}"
        type = method.to_s.sub("kredis_", "")

        define_method(name) do
          if instance_variable_defined?(ivar_symbol)
            instance_variable_get(ivar_symbol)
          else
            instance_variable_set(ivar_symbol, Kredis.send(type, kredis_key_evaluated(key) || kredis_key_for_attribute(name), **options))
          end
        end
      end
  end

  private
    def kredis_key_evaluated(key)
      case key
      when String then key
      when Proc   then key.call(self)
      end
    end

    def kredis_key_for_attribute(name)
      "#{self.class.name.tableize.gsub("/", ":")}:#{id}:#{name}"
    end
end
