module Kredis::TypeCasting
  def type_to_string(value)
    case value
    when nil
      ""
    when Time, DateTime, ActiveSupport::TimeWithZone
      value.to_f
    when Integer
      value.to_s
    when BigDecimal
      value.to_d
    when Float
      value.to_s
    when TrueClass, FalseClass
      value ? "t" : "f"
    else
      value
    end
  end

  def string_to_type(value, type)
    case type
    when nil        then value
    when "datetime" then Time.at(value.to_i)
    when "integer"  then value.to_i
    when "decimal"  then value.to_d
    when "float"    then value.to_f
    when "boolean"  then value == "t" ? true : false
    end if value.present?
  end

  def types_to_strings(values)
    Array(values).flatten.map { |value| type_to_string(value) }
  end

  def strings_to_types(values, type)
    Array(values).flatten.map { |value| string_to_type(value, type) }
  end
end
