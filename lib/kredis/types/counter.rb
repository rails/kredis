class Kredis::Types::Counter < Kredis::Types::Proxying
  proxying :multi, :set, :incrby, :decrby, :get, :del, :exists?

  before_methods :value, :increment, :decrement, invoke: :set_default

  attr_accessor :expires_in

  def increment(by: 1)
    incrby by
  end

  def decrement(by: 1)
    decrby by
  end

  def value
    get.to_i
  end

  def reset
    del
  end

  private

    def value=(new_value)
      set(new_value.to_i, ex: expires_in, nx: true)
    end

    def set_default
      return if exists?

      value = @default.is_a?(Proc) ? @default.call : @default
      self.value = value
    end
end
