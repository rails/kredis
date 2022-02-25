# You'd normally call this a set, but Redis already has another data type for that
class Kredis::Types::UniqueList < Kredis::Types::Proxying
  proxying :multi, :zrange, :zrem, :zadd, :zremrangebyrank, :zcard, :exists?, :del

  attr_accessor :typed, :limit

  def elements
    auto_fallback(:elements) do
      strings_to_types(zrange(0, -1) || [], typed)
    end
  end
  alias to_a elements

  def remove(*elements)
    auto_migrate do
      zrem(types_to_strings(elements, typed))
    end
  end

  def prepend(elements)
    auto_migrate do
      insert(elements, prepending: true)
    end
  end

  def append(elements)
    auto_migrate do
      insert(elements)
    end
  end
  alias << append

  private
    def insert(elements, prepending: false)
      elements = Array(elements)
      return if elements.empty?

      elements_with_scores = types_to_strings(elements, typed).map.with_index do |element, index|
        score = generate_base_score(negative: prepending) + index / 100000

        [ score , element ]
      end

      multi do
        zadd(elements_with_scores)
        trim(from_beginning: prepending)
      end
    end

    def generate_base_score(negative:)
      current_time = process_start_time + process_uptime

      negative ? -current_time : current_time
    end

    def process_start_time
      @process_start_time ||= redis.time.join(".").to_f - process_uptime
    end

    def process_uptime
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def trim(from_beginning:)
      return unless limit&.positive?

      if from_beginning
        zremrangebyrank(limit, -1)
      else
        zremrangebyrank(0, -(limit + 1))
      end
    end

    def auto_fallback(method)
      yield
    rescue Redis::CommandError
      legacy_list.send(method)
    end

    def auto_migrate
      yield
    rescue Redis::CommandError
      migrate_list_to_sorted_set
      retry
    end

    def migrate_list_to_sorted_set
      legacy_elements = legacy_list.elements
      legacy_list.rename([ legacy_list.key, "_backup" ].join)
      append(legacy_elements)
    end

    def legacy_list
      Kredis.unique_list_legacy(key, typed: typed, limit: limit, config: config, after_change: after_change)
    end
end
