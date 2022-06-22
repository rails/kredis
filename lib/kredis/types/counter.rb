class Kredis::Types::Counter < Kredis::Types::Proxying
  include Kredis::Types::Expirable

  proxying :multi, :set, :incrby, :decrby, :get, :del, :exists?

  def increment(by: 1)
    multi do |pipeline|
      pipeline.set 0, nx: true
      pipeline.incrby by
      refresh_expiration
    end[-1]
  end

  def decrement(by: 1)
    multi do |pipeline|
      pipeline.set 0, nx: true
      pipeline.decrby by
      refresh_expiration
    end[-1]
  end

  def value
    get.to_i
  end

  def reset
    del
  end
end
