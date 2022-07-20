class Kredis::Types::Counter < Kredis::Types::Proxying
  proxying :multi, :set, :incrby, :decrby, :get, :del, :exists?

  attr_accessor :expires_in

  def increment(by: 1)
    multi do
      initialize_with_default
      incrby by
    end[-1]
  end

  def decrement(by: 1)
    multi do
      initialize_with_default
      decrby by
    end[-1]
  end

  def value
    (get || default).to_i
  end

  def reset
    del
  end

  private
    def initialize_with_default
      set default.to_i, ex: expires_in, nx: true
    end
end
