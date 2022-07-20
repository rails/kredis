class Kredis::Types::Counter < Kredis::Types::Proxying
  proxying :multi, :set, :incrby, :decrby, :get, :del, :exists?

  attr_accessor :expires_in

  def increment(by: 1)
    init_default_in_multi { incrby by }
  end

  def decrement(by: 1)
    init_default_in_multi { decrby by }
  end

  def value
    (get || default).to_i
  end

  def reset
    del
  end

  private
    def set_default(value)
      set value.to_i, ex: expires_in, nx: true
    end

    def default
      super.to_i
    end
end
