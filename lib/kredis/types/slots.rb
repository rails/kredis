class Kredis::Types::Slots < Kredis::Types::Proxy
  class NotAvailable < StandardError; end

  attr_accessor :available

  def reserve
    if block_given?
      begin
        if reserve
          yield
          true
        else
          false
        end
      ensure
        release
      end
    else
      if incr <= available
        true
      else
        release
        false
      end
    end
  end

  def release
    decr
  end

  def available?
    get.to_i < available
  end

  def reset
    del
  end
end
