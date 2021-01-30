class Kredis::Types::Mutex < Kredis::Types::Proxy
  def initialize(redis, key, expires_in: nil)
    @expires_in = expires_in
    super redis, key
  end

  def lock
    set 1, ex: @expires_in
  end

  def unlock
    del
  end

  def locked?
    get
  end

  def synchronize
    lock
    yield
  ensure
    unlock
  end
end
