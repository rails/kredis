class Kredis::Types::Scalar < Kredis::Types::Proxying
  proxying :set, :get, :exists?, :del, :expire, :expireat

  attr_accessor :typed, :default, :expires_in

  def value=(value)
    set type_to_string(value, typed), ex: expires_in
  end

  def value
    string_to_type(get, typed)
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

    def default
      return @default unless @default.is_a? Proc

      @default.call.tap { |default_value| self.value = default_value }
    end
end
