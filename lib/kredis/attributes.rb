# frozen_string_literal: true

module Kredis::Attributes
  extend ActiveSupport::Concern

  class_methods do
    def kredis_proxy(name, key: nil, config: :shared, after_change: nil)
      kredis_connection_with __method__, name, key, config: config, after_change: after_change
    end

    def kredis_string(name, key: nil, default: nil, config: :shared, after_change: nil, expires_in: nil)
      kredis_connection_with __method__, name, key, default: default, config: config, after_change: after_change, expires_in: expires_in
    end

    def kredis_integer(name, key: nil, default: nil, config: :shared, after_change: nil, expires_in: nil)
      kredis_connection_with __method__, name, key, default: default, config: config, after_change: after_change, expires_in: expires_in
    end

    def kredis_decimal(name, key: nil, default: nil, config: :shared, after_change: nil, expires_in: nil)
      kredis_connection_with __method__, name, key, default: default, config: config, after_change: after_change, expires_in: expires_in
    end

    def kredis_datetime(name, key: nil, default: nil, config: :shared, after_change: nil, expires_in: nil)
      kredis_connection_with __method__, name, key, default: default, config: config, after_change: after_change, expires_in: expires_in
    end

    def kredis_flag(name, key: nil, default: nil, config: :shared, after_change: nil, expires_in: nil)
      kredis_connection_with __method__, name, key, default: default, config: config, after_change: after_change, expires_in: expires_in

      define_method("#{name}?") do
        send(name).marked?
      end
    end

    def kredis_float(name, key: nil, default: nil, config: :shared, after_change: nil, expires_in: nil)
      kredis_connection_with __method__, name, key, default: default, config: config, after_change: after_change, expires_in: expires_in
    end

    def kredis_enum(name, key: nil, values:, default:, config: :shared, after_change: nil)
      kredis_connection_with __method__, name, key, values: values, default: default, config: config, after_change: after_change
    end

    def kredis_json(name, key: nil, default: nil, config: :shared, after_change: nil, expires_in: nil)
      kredis_connection_with __method__, name, key, default: default, config: config, after_change: after_change, expires_in: expires_in
    end

    def kredis_list(name, key: nil, default: nil, typed: :string, config: :shared, after_change: nil)
      kredis_connection_with __method__, name, key, default: default, typed: typed, config: config, after_change: after_change
    end

    def kredis_unique_list(name, limit: nil, key: nil, default: nil, typed: :string, config: :shared, after_change: nil)
      kredis_connection_with __method__, name, key, default: default, limit: limit, typed: typed, config: config, after_change: after_change
    end

    def kredis_set(name, key: nil, default: nil, typed: :string, config: :shared, after_change: nil)
      kredis_connection_with __method__, name, key, default: default, typed: typed, config: config, after_change: after_change
    end

    def kredis_ordered_set(name, limit: nil, default: nil, key: nil, typed: :string, config: :shared, after_change: nil)
      kredis_connection_with __method__, name, key, default: default, limit: limit, typed: typed, config: config, after_change: after_change
    end

    def kredis_slot(name, key: nil, config: :shared, after_change: nil)
      kredis_connection_with __method__, name, key, config: config, after_change: after_change
    end

    def kredis_slots(name, available:, key: nil, config: :shared, after_change: nil)
      kredis_connection_with __method__, name, key, available: available, config: config, after_change: after_change
    end

    def kredis_counter(name, key: nil, default: nil, config: :shared, after_change: nil, expires_in: nil)
      kredis_connection_with __method__, name, key, default: default, config: config, after_change: after_change, expires_in: expires_in
    end

    def kredis_hash(name, key: nil, default: nil, typed: :string, config: :shared, after_change: nil)
      kredis_connection_with __method__, name, key, default: default, typed: typed, config: config, after_change: after_change
    end

    def kredis_boolean(name, key: nil, default: nil, config: :shared, after_change: nil, expires_in: nil)
      kredis_connection_with __method__, name, key, default: default, config: config, after_change: after_change, expires_in: expires_in
    end

    private
      def kredis_connection_with(method, name, key, **options)
        ivar_symbol = :"@#{name}_#{method}"
        type = method.to_s.sub("kredis_", "")
        after_change = options.delete(:after_change)

        define_method(name) do
          if instance_variable_defined?(ivar_symbol)
            instance_variable_get(ivar_symbol)
          else
            options[:default] = kredis_default_evaluated(options[:default]) if options[:default]
            new_type = Kredis.send(type, kredis_key_evaluated(key) || kredis_key_for_attribute(name), **options)
            instance_variable_set ivar_symbol,
              after_change ? enrich_after_change_with_record_access(new_type, after_change) : new_type
          end
        end
      end
  end

  private
    def kredis_key_evaluated(key)
      case key
      when String then key
      when Proc   then key.call(self)
      when Symbol then send(key)
      end
    end

    def kredis_key_for_attribute(name)
      "#{self.class.name.tableize.tr("/", ":")}:#{extract_kredis_id}:#{name}"
    end

    def extract_kredis_id
      try(:id) or raise NotImplementedError, "kredis needs a unique id, either implement an id method or pass a custom key."
    end

    def enrich_after_change_with_record_access(type, original_after_change)
      case original_after_change
      when Proc   then Kredis::Types::CallbacksProxy.new(type, ->(_) { original_after_change.call(self) })
      when Symbol then Kredis::Types::CallbacksProxy.new(type, ->(_) { send(original_after_change) })
      end
    end

    def kredis_default_evaluated(default)
      case default
      when Proc   then Proc.new { default.call(self) }
      when Symbol then send(default)
      else default
      end
    end
end
