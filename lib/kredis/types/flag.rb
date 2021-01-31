class Kredis::Types::Flag < Kredis::Types::Proxy
  def mark(expires_in: nil)
    set 1, ex: expires_in
  end

  def marked?
    exists?
  end

  def remove
    del
  end
end
