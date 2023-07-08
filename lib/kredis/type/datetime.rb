# frozen_string_literal: true

module Kredis
  module Type
    class DateTime < ActiveModel::Type::DateTime
      def serialize(value)
        super&.utc&.iso8601(9)
      end

      def cast_value(value)
        super&.to_time
      end
    end
  end
end
