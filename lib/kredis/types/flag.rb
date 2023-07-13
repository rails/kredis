# frozen_string_literal: true

class Kredis::Types::Flag < Kredis::Types::Proxying
  prepend Kredis::DefaultValues

  proxying :set, :exists?, :del

  attr_accessor :expires_in

  def mark(expires_in: nil, force: true)
    set 1, ex: expires_in || self.expires_in, nx: !force
  end

  def marked?
    exists?
  end

  def remove
    del
  end

  private
    def set_default
      mark if default
    end
end
