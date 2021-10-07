class Kredis::Types::Slots < Kredis::Types::Proxying
  class NotAvailable < StandardError; end

  proxying :incr, :decr, :get, :del, :exists?

  attr_accessor :available

  def reserve
    failsafe returning: false do
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
  end

  def release
    decr
  end

  def available?
    failsafe returning: false do
      get.to_i < available
    end
  end

  def reset
    del
  end
end
