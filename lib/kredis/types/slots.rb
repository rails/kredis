class Kredis::Types::Slots < Kredis::Types::Proxying
  class NotAvailable < StandardError; end

  proxying :incr, :decr, :get, :del, :exists?, :eval

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
        eval RESERVE_SCRIPT, available
      end
    end
  end

  def release
    eval RELEASE_SCRIPT
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

  private

  RESERVE_SCRIPT = <<~LUA.freeze
    local current_value = (tonumber(redis.call("get", KEYS[1])) or 0)
    if current_value < tonumber(ARGV[1]) then
      redis.call("incr", KEYS[1])
      return true
    else
      return false
    end
  LUA

  RELEASE_SCRIPT = <<~LUA.freeze
    local current_value = (tonumber(redis.call("get", KEYS[1])) or 0)
    if current_value > 0 then
      redis.call("decr", KEYS[1])
      return true
    else
      return false
    end
  LUA
end
