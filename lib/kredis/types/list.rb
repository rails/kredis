class Kredis::Types::List < Kredis::Types::Proxying
  proxying :lrange, :lrem, :lpush, :rpush, :exists?, :del, :expire, :ttl

  attr_accessor :typed, :expires_in

  def elements
    strings_to_types(lrange(0, -1) || [], typed)
  end
  alias to_a elements

  def remove(*elements, pipeline: nil)
    types_to_strings(elements, typed).each { |element| (pipeline || proxy).lrem 0, element }
    refresh_expiration(pipeline || proxy)
  end

  def prepend(*elements, pipeline: nil)
    (pipeline || proxy).lpush types_to_strings(elements, typed) if elements.flatten.any?
    refresh_expiration(pipeline || proxy)
  end

  def append(*elements, pipeline: nil)
    (pipeline || proxy).rpush types_to_strings(elements, typed) if elements.flatten.any?
    refresh_expiration(pipeline || proxy)
  end
  alias << append

  def clear
    del
  end

  private
    def refresh_expiration(target)
      target.expire expires_in.to_i if expires_in
    end
end
