# frozen_string_literal: true

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
        if available?
          incr
          true
        else
          false
        end
      end
    end
  end

  def release
    if taken > 0
      decr
      true
    else
      false
    end
  end

  def available?
    failsafe returning: false do
      taken < available
    end
  end

  def reset
    del
  end

  def taken
    get.to_i
  end
end
