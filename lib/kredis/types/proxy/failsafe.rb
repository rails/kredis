module Kredis::Types::Proxy::Failsafe
  extend ActiveSupport::Concern

  included do
    mattr_accessor :fail_safe_enabled, default: true
  end

  def failsafe(returning: nil, &block)
    if fail_safe_enabled?
      suppress_fail_safe_with(returning: returning, &block)
    else
      yield
    end
  rescue Redis::BaseError
    raise if fail_safe_disabled? || fail_safe_suppressed?
  end

  def suppress_fail_safe_with(returning: nil)
    old_fail_safe_suppressed, @fail_safe_suppressed = @fail_safe_suppressed, true
    yield
  rescue Redis::BaseError
    returning
  ensure
    @fail_safe_suppressed = old_fail_safe_suppressed
  end

  private
    def fail_safe_enabled?
      fail_safe_enabled
    end

    def fail_safe_disabled?
      !fail_safe_enabled
    end

    def fail_safe_suppressed?
      @fail_safe_suppressed
    end
end
