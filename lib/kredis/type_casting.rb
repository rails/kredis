# frozen_string_literal: true

require "json"
require "active_model/type"
require "kredis/type/boolean"
require "kredis/type/datetime"
require "kredis/type/json"

module Kredis::TypeCasting
  class InvalidType < StandardError; end

  TYPES = {
    string: ActiveModel::Type::String.new,
    integer: ActiveModel::Type::Integer.new,
    decimal: ActiveModel::Type::Decimal.new,
    float: ActiveModel::Type::Float.new,
    boolean: Kredis::Type::Boolean.new,
    datetime: Kredis::Type::DateTime.new,
    json: Kredis::Type::Json.new
  }

  def type_to_string(value, type)
    raise InvalidType if type && !TYPES.key?(type)

    TYPES[type || :string].serialize(value)
  end

  def string_to_type(value, type)
    raise InvalidType if type && !TYPES.key?(type)

    TYPES[type || :string].cast(value)
  end

  def types_to_strings(values, type)
    Array(values).flatten.map { |value| type_to_string(value, type) }
  end

  def strings_to_types(values, type)
    Array(values).flatten.map { |value| string_to_type(value, type) }
  end
end
