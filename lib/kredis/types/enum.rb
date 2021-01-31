class Kredis::Types::Enum < Kredis::Types::Proxy
  attr_accessor :values, :default

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
    get || default
  end

  def reset
    del
  end

  private
    def define_predicates_for_values
      values.each do |defined_value|
        define_singleton_method("#{defined_value}?") { value == defined_value }
      end
    end
end
