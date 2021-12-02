# You'd normally call this a set, but Redis already has another data type for that
class Kredis::Types::UniqueList < Kredis::Types::List
  proxying :multi, :ltrim, :exists?

  attr_accessor :typed, :limit

  def prepend(elements)
    multi do
      remove elements
      super
      ltrim 0, (limit - 1) if limit
    end if Array(elements).flatten.any?
  end

  def append(elements)
    multi do
      remove elements
      super
      ltrim -limit, -1 if limit
    end if Array(elements).flatten.any?
  end
  alias << append
end
