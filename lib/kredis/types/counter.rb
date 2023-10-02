# frozen_string_literal: true

class Kredis::Types::Counter < Kredis::Types::Proxying
  prepend Kredis::DefaultValues

  proxying :multi, :set, :incrby, :decrby, :get, :del, :exists?

  attr_accessor :expires_in

  def increment(by: 1)
    multi do
      set 0, ex: expires_in, nx: true if expires_in
      incrby by
    end[-1]
  end

  def decrement(by: 1)
    multi do
      set 0, ex: expires_in, nx: true if expires_in
      decrby by
    end[-1]
  end

  def value
    get.to_i
  end

  def reset
    del
  end

  private
    def set_default
      increment by: default
    end
end
