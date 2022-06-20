class Kredis::Types::Flag < Kredis::Types::Proxying
  proxying :set, :exists?, :del

  attr_accessor :expires_in

  def mark(expires_in: nil, force: true)
    set 1, ex: expires_in || self.expires_in, nx: !force
  end

  def marked?
    exists? || exists_after_default_value?
  end

  def remove
    del
  end

  private
    def exists_after_default_value?
      !!default do |default_value|
        mark if default_value
        !!default_value
      end
    end
end
