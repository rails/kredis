class Kredis::Types::Flag < Kredis::Types::Proxying
  proxying :set, :exists?, :del

  invoke_after_change_on :mark, :remove

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
