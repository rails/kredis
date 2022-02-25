# You'd normally call this a set, but Redis already has another data type for that
class Kredis::Types::UniqueList < Kredis::Types::Proxying
  proxying :zrange, :zrem, :zadd, :zremrangebyrank, :exists?, :del

  attr_accessor :typed, :limit

  def elements
    strings_to_types(zrange(0, -1) || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    zrem(types_to_strings(elements, typed))
  end

  def prepend(elements)
    insert(elements, prepend: true)
  end

  def append(elements)
    insert(elements)
  end
  alias << append

  private
    def insert(elements, prepend: false)
      elements = Array(elements)
      return if elements.empty?

      elements_with_scores = types_to_strings(elements, typed).map do |element|
        [ current_nanoseconds(negative: prepend), element ]
      end

      zadd(elements_with_scores)

      trim(from_beginning: prepend)
    end

    def current_nanoseconds(negative:)
      "%10.9f" % (negative ? -Time.now.to_f : Time.now.to_f)
    end

    def trim(from_beginning:)
      if limit&.positive?
        if from_beginning
          zremrangebyrank(limit, -1)
        else
          zremrangebyrank(0, -(limit + 1))
        end
      end
    end
end
