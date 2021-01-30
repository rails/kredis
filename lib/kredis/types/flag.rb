class Kredis::Types::Flag < Kredis::Proxy
  def mark
    set 1
  end

  def marked?
    exists?
  end

  def remove
    del
  end
end
