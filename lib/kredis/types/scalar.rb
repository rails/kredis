class Kredis::Types::Scalar < Kredis::Types::Proxying
  proxying :set, :get, :exists?, :del, :expire, :expireat

  attr_accessor :typed, :expires_in

  def value=(value)
    set type_to_string(value, typed), ex: expires_in
  end

  def value
    string_to_type(get || initialize_with_default, typed)
  end

  def to_s
    value&.to_s
  end

  def assigned?
    exists?
  end

  def clear
    del
  end

  def expire_in(seconds)
    expire seconds.to_i
  end

  def expire_at(datetime)
    expireat datetime.to_i
  end

  private
    def initialize_with_default
      default { |default_value| self.value = default_value }
    end
end
