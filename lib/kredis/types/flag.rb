class Kredis::Types::Flag < Kredis::Types::Proxying
  proxying :set, :exists?, :del

  attr_accessor :expires_in

  def mark(expires_in: nil, force: true)
    set 1, ex: expires_in || self.expires_in, nx: !force
  end

  def marked?
    exists? || default?
  end

  def remove
    del
  end

  private

    def default?
      return false unless @default && @default.is_a?(Proc) && @default.call

      mark && true
    end
end
