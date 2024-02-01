# frozen_string_literal: true

# You'd normally call this a set, but Redis already has another data type for that
class Kredis::Types::UniqueList < Kredis::Types::List
  proxying :multi, :ltrim, :exists?
  include Kredis::Expiration

  attr_accessor :typed, :limit

  def prepend(elements)
    elements = Array(elements).uniq
    return if elements.empty?

    with_expiration do

      multi do
        remove elements
        super(elements, suppress_expiration: true)
        ltrim 0, (limit - 1) if limit
      end
    end
  end

  def append(elements)
    elements = Array(elements).uniq
    return if elements.empty?

    with_expiration do

      multi do
        remove elements
        super(elements, suppress_expiration: true)
        ltrim(-limit, -1) if limit
      end
    end
  end
  alias << append
end
