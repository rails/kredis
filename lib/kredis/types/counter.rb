class Kredis::Types::Counter < Kredis::Types::Proxying
  proxying :multi, :set, :incrby, :decrby, :get, :del, :exists?

  attr_accessor :expires_in

  def increment(by: 1)
    set_default unless exists?
    incrby by
  end

  def decrement(by: 1)
    set_default unless exists?
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
      value
    end

    def default
      return self.value = @default unless @default.is_a? Proc

      @default.call.tap { |value| self.value = value }
    end
    alias set_default default
end
