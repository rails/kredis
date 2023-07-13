# frozen_string_literal: true

module Kredis
  module Type
    class Boolean < ActiveModel::Type::Boolean
      def serialize(value)
        super ? 1 : 0
      end
    end
  end
end
