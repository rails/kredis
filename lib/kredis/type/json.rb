# frozen_string_literal: true

module Kredis
  module Type
    class Json < ActiveModel::Type::Value
      def type
        :json
      end

      def cast_value(value)
        JSON.parse(value)
      end

      def serialize(value)
        JSON.dump(value)
      end
    end
  end
end
