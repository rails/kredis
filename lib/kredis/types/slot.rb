# For distributed locks where you want a `max` of available units of work to happen concurrently.
class Kredis::Types::Slot < Kredis::Types::Proxy
  class NoAvailableSlotsError < StandardError; end

  attr_accessor :available_slot_count, :max_acquire_attempts

  def initialize(*)
    super
    @max_acquire_attempts ||= available_slot_count / 5
    @original_key = key
  end

  def acquire
    attempts = 0

    @redis.exists(*slot_keys).find do |key|
      if @redis.set key, slot_id, nx: true
        @key = key
      else
        attempts += 1
        raise NoAvailableSlotsError unless attempts < max_acquire_attempts
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
      available_slot_count.times { |index| "#{@original_key}/slot/#{index}" }
    end

    def slot_id
      @slot_id ||= rand(1_000).to_s
    end
end
