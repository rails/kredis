# frozen_string_literal: true

module Kredis::Types::Proxy::Failsafe
  def initialize(*)
    super
    @fail_safe_suppressed = false
  end

  def failsafe
    yield
  rescue Redis::BaseError
    raise if fail_safe_suppressed?
  end

  def suppress_failsafe_with(returning: nil)
    old_fail_safe_suppressed, @fail_safe_suppressed = @fail_safe_suppressed, true
    yield
  rescue Redis::BaseError
    returning
  ensure
    @fail_safe_suppressed = old_fail_safe_suppressed
  end

  private
    def fail_safe_suppressed?
      @fail_safe_suppressed
    end
end
