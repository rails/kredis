# frozen_string_literal: true

module Kredis
  module Type
    class Json < ActiveModel::Type::Value
      def type
        :json
      end

      def cast_value(value)
        return value.stringify_keys if value.is_a? Hash

        JSON.load(value)
      end

      def serialize(value)
        JSON.dump(value)
      end
    end
  end
end
