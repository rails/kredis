module Kredis::Types::Proxy::Failsafe
  extend ActiveSupport::Concern

  included do
    mattr_accessor :fail_safe_enabled, default: true
  end

  def failsafe(returning: nil, &block)
    if fail_safe_enabled? && !fail_safe_suppressed?
      rescue_redis_errors_with(returning: returning, &block)
    else
      yield
    end
  end

  private
    def fail_safe_enabled?
      fail_safe_enabled
    end

    def fail_safe_suppressed?
      @fail_safe_suppressed
    end

    def rescue_redis_errors_with(returning: nil)
      old_fail_safe_suppressed, @fail_safe_suppressed = @fail_safe_suppressed, true
      yield
    rescue Redis::BaseError
      returning
    ensure
      @fail_safe_suppressed = old_fail_safe_suppressed
    end
end
