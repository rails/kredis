class Kredis::Types::Counter < Kredis::Types::Proxying
  proxying :multi, :set, :get, :del, :exists?

  attr_accessor :expires_in

  def increment(by: 1)
    multi do |pipeline|
      pipeline.set key, 0, ex: expires_in, nx: true
      pipeline.incrby key, by
    end
  end

  def decrement(by: 1)
    multi do |pipeline|
      pipeline.set key, 0, ex: expires_in, nx: true
      pipeline.decrby key, by
    end
  end

  def value
    get.to_i
  end

  def reset
    del
  end
end
