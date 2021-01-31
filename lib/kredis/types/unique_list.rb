# You'd normally call this a set, but Redis already has another data type for that
class Kredis::Types::UniqueList < Kredis::Types::List
  attr_accessor :limit

  def prepend(elements)
    with_trimming_of(elements, to: limit_index) { super }
  end

  def append(elements)
    with_trimming_of(elements, from: limit_index) { super }
  end

  private
    def with_trimming_of(elements, from: 0, to: -1)
      multi do
        remove elements
        yield
        ltrim from, to if limit
      end if Array(elements).any?
    end

    def limit_index
      limit - 1 if limit
    end
end
