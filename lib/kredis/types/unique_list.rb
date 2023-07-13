# frozen_string_literal: true

# You'd normally call this a set, but Redis already has another data type for that
class Kredis::Types::UniqueList < Kredis::Types::List
  proxying :multi, :ltrim, :exists?

  attr_accessor :typed, :limit

  def prepend(elements)
    elements = Array(elements).uniq
    return if elements.empty?

    multi do
      remove elements
      super
      ltrim 0, (limit - 1) if limit
    end
  end

  def append(elements)
    elements = Array(elements).uniq
    return if elements.empty?

    multi do
      remove elements
      super
      ltrim(-limit, -1) if limit
    end
  end
  alias << append
end
