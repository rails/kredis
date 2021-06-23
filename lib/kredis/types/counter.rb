class Kredis::Types::Counter < Kredis::Types::Proxying
  proxying :multi, :set, :incrby, :decrby, :get, :del

  attr_accessor :expires_in

  def callback_operations
    %i[increment decrement reset].freeze
  end

  def increment(by: 1)
    multi do
      set 0, ex: expires_in, nx: true
      incrby by
    end
  end

  def decrement(by: 1)
    multi do
      set 0, ex: expires_in, nx: true
      decrby by
    end
  end

  def value
    get.to_i
  end

  def reset
    del
  end
end
