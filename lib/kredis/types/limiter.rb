# frozen_string_literal: true

# A limiter is a specialized form of a counter that can be checked whether it has been exceeded and is provided fail safe. This means it can be used to guard login screens from brute force attacks without denying access in case Redis is offline.
#
# It will usually be used as an expiring limiter. Note that the limiter expires in total after the `expires_in` time used upon the first poke.
#
# It offers no guarentee that you can't poke yourself above the limit. You're responsible for checking `#exceeded?` yourself first, and this may produce a race condition. So only use this when the exact number of pokes is not critical.
class Kredis::Types::Limiter < Kredis::Types::Counter
  class LimitExceeded < StandardError; end

  attr_accessor :limit

  def poke
    failsafe returning: true do
      increment
    end
  end

  def exceeded?
    failsafe returning: false do
      value >= limit
    end
  end
end
