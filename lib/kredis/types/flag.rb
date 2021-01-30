class Kredis::Types::Flag < Kredis::Types::Proxy
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
