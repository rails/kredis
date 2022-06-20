# frozen_string_literal: true

module Kredis
  module Type
    class Json < ActiveModel::Type::Value
      def type
        :json
      end

      def cast_value(value)
        if value.is_a? Hash
          value.stringify_keys
        else
          JSON.load(value)
        end
      end

      def serialize(value)
        JSON.dump(value)
      end
    end
  end
end
