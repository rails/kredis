class Kredis::Types::Flag < Kredis::Types::Proxying
  proxying :set, :exists?, :del

  def callback_operations
    %i[mark remove].freeze
  end

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
