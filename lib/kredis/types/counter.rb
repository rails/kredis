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
    def set_default
      set(default.to_i, ex: expires_in, nx: true) unless exists?
    end
end
