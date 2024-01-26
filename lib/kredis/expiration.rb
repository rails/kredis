# frozen_string_literal: true

module Kredis::Expiration
  extend ActiveSupport::Concern

  included do
    proxying :ttl, :expire
    attr_accessor :expires_in
  end

  private
    def with_expiration(&block)
      result = block.call
      if expires_in && ttl < 0
        expire expires_in.to_i
      end
      result
    end
end
