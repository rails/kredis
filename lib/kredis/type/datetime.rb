# frozen_string_literal: true

module Kredis
  module Type
    class DateTime < ActiveModel::Type::DateTime
      def serialize(value)
        super&.iso8601(9)
      end

      def cast_value(value)
        super&.to_datetime
      end
    end
  end
end
