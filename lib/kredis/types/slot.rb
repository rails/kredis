# For distributed locks where you want a `max` of available units of work to happen concurrently.
class Kredis::Types::Slot < Kredis::Types::Proxy
  attr_accessor :max

  def initialize(*)
    super
    @original_key = key
  end

  def acquire
    @redis.exists(*slot_keys).find do |key|
      if @redis.set key, slot_id, nx: true
        @key = key
      end
    end
  end

  def assigned?
    get == slot_id
  end

  def waive
    del
  end

  private
    def slot_keys
      max.times { |index| "#{@original_key}/slot/#{index}" }
    end

    def slot_id
      @slot_id ||= rand(1_000).to_s
    end
end
