# frozen_string_literal: true

require "active_support/core_ext/object/inclusion"

class Kredis::Types::Enum < Kredis::Types::Proxying
  prepend Kredis::DefaultValues

  InvalidDefault = Class.new(StandardError)

  proxying :set, :get, :del, :exists?, :multi

  attr_accessor :values

  def initialize(...)
    super
    define_predicates_for_values
  end

  def value=(value)
    if validated_choice = value.presence_in(values)
      set validated_choice
    end
  end

  def value
    get
  end

  def reset
    multi do
      del
      set_default
    end
  end

  private
    def define_predicates_for_values
      values.each do |defined_value|
        define_singleton_method("#{defined_value}?") { value == defined_value }
        define_singleton_method("#{defined_value}!") { self.value = defined_value }
      end
    end

    def set_default
      if default.in?(values) || default.nil?
        set default
      else
        raise InvalidDefault, "Default value #{default.inspect} for #{key} is not a valid option (Valid values: #{values.join(", ")})"
      end
    end
end
