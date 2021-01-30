class Kredis::Types::Counter < Kredis::Types::Proxy
  def initialize(redis, key, expires_in: nil)
    @expires_in = expires_in
    super redis, key
  end

  def increment(by: 1)
    multi do
      set 0, ex: @expires_in, nx: true
      incrby by
    end
  end

  def value
    get.to_i
  end
end
