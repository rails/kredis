class Kredis::Types::Scalar < Kredis::Types::Proxying
  proxying :set, :get, :exists?, :del

  attr_accessor :typed, :default

  def callback_operations
    %i[value= clear].freeze
  end

  def value=(value)
    set type_to_string(value)
  end

  def value
    string_to_type(get, typed) || default
  end

  def to_s
    get || default&.to_s
  end

  def assigned?
    exists?
  end

  def clear
    del
  end
end
