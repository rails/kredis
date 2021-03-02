require "json"
require "active_model/type"
require "kredis/type/json"

module Kredis::TypeCasting
  class InvalidType < StandardError; end

  TYPES = {
    string: ActiveModel::Type::String.new,
    integer: ActiveModel::Type::Integer.new,
    decimal: ActiveModel::Type::Decimal.new,
    float: ActiveModel::Type::Decimal.new,
    boolean: ActiveModel::Type::Boolean.new,
    datetime: ActiveModel::Type::DateTime.new,
    json: Kredis::Type::Json.new
  }

  def type_to_string(value)
    case value
    when nil
      ""
    when Integer
      value.to_s
    when BigDecimal
      value.to_d
    when Float
      value.to_s
    when TrueClass, FalseClass
      value ? "t" : "f"
    when Time, DateTime, ActiveSupport::TimeWithZone
      value.iso8601(9)
    when Hash
      JSON.dump(value)
    else
      value
    end
  end

  def string_to_type(value, type)
    raise InvalidType if type && !TYPES.key?(type)

    TYPES[type || :string].cast(value)
  end

  def types_to_strings(values)
    Array(values).flatten.map { |value| type_to_string(value) }
  end

  def strings_to_types(values, type)
    Array(values).flatten.map { |value| string_to_type(value, type) }
  end
end
