# You'd normally call this a set, but Redis already has another data type for that
class Kredis::Types::UniqueList < Kredis::Types::List
  proxying :multi, :ltrim, :exists?

  attr_accessor :typed, :limit

  def prepend(elements)
    elements = Array(elements).uniq
    return if elements.empty?

    multi do |pipeline|
      remove elements, pipeline: pipeline
      super(elements, pipeline: pipeline)
      pipeline.ltrim 0, (limit - 1) if limit
    end
  end

  def append(elements)
    elements = Array(elements).uniq
    return if elements.empty?

    multi do |pipeline|
      remove elements, pipeline: pipeline
      super(elements, pipeline: pipeline)
      pipeline.ltrim -limit, -1 if limit
    end
  end
  alias << append
end
