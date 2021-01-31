class Kredis::Types::Mutex < Kredis::Types::Proxy
  attr_accessor :expires_in

  def lock
    set 1, ex: expires_in
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
