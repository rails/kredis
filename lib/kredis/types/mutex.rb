class Kredis::Types::Mutex < Kredis::Types::Proxy
  attr_accessor :expires_in

  def lock
    set lock_id, ex: expires_in, nx: true
  end

  def unlock
    del if lock_acquired?
  end

  def locked?
    get
  end

  def synchronize
    yield if lock && lock_acquired?
  ensure
    unlock
  end

  private
    def lock_acquired?
      get&.to_i == lock_id
    end

    def lock_id
      @lock_id ||= rand(1_000_000)
    end
end
