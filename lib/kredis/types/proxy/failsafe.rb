module Kredis::Types::Proxy::Failsafe
  extend ActiveSupport::Concern

  mattr_accessor :enabled, default: true

  def failsafe(returning: nil, &block)
    if enabled? && !suppressed?
      rescue_redis_errors_with(returning: returning, &block)
    else
      yield
    end
  end

  private
    def enabled?
      enabled
    end

    def suppressed?
      @suppressed
    end

    def rescue_redis_errors_with(returning: nil)
      old_suppressed, @suppressed = @suppressed, true
      yield
    rescue Redis::BaseError
      returning
    ensure
      @suppressed = old_suppressed
    end
end
