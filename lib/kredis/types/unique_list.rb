# You'd normally call this a set, but Redis already has another data type for that
class Kredis::Types::UniqueList < Kredis::Types::List
  proxying :multi, :exists?

  attr_accessor :typed, :limit

  def prepend(elements)
    elements = Array(elements).uniq
    return if elements.empty?

    multi do |pipeline|
      types_to_strings(elements, typed).each { |element| pipeline.lrem key, 0, element }
      super
      pipeline.ltrim key, 0, (limit - 1) if limit
    end
  end

  def append(elements)
    elements = Array(elements).uniq
    return if elements.empty?

    multi do |pipeline|
      types_to_strings(elements, typed).each { |element| pipeline.lrem key, 0, element }
      super
      pipeline.ltrim key, -limit, -1 if limit
    end
  end
  alias << append
end
