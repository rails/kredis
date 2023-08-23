# frozen_string_literal: true

class Kredis::Types::OrderedSet < Kredis::Types::Proxying
  prepend Kredis::DefaultValues

  proxying :multi, :zrange, :zrem, :zadd, :zremrangebyrank, :zcard, :exists?, :del, :zscore

  attr_accessor :typed
  attr_reader :limit

  def elements
    strings_to_types(zrange(0, -1) || [], typed)
  end
  alias to_a elements

  def remove(*elements)
    zrem(types_to_strings(elements, typed))
  end

  def include?(element)
    !!zscore(type_to_string(element, typed))
  end

  def prepend(elements)
    insert(elements, prepending: true)
  end

  def append(elements)
    insert(elements)
  end
  alias << append

  def limit=(limit)
    raise "Limit must be greater than 0" if limit && limit <= 0

    @limit = limit
  end

  private
    def insert(elements, prepending: false)
      elements = Array(elements)
      return if elements.empty?

      elements_with_scores = types_to_strings(elements, typed).map.with_index do |element, index|
        incremental_score = index * 0.000001

        score = if prepending
          -base_score - incremental_score
        else
          base_score + incremental_score
        end

        [ score, element ]
      end

      multi do
        zadd(elements_with_scores)
        trim(from_beginning: prepending)
      end
    end

    def base_score
      process_start_time + process_uptime
    end

    def process_start_time
      @process_start_time ||= unproxied_redis.time.join(".").to_f - process_uptime
    end

    def process_uptime
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def trim(from_beginning:)
      return unless limit

      if from_beginning
        zremrangebyrank(limit, -1)
      else
        zremrangebyrank(0, -(limit + 1))
      end
    end

    def set_default
      append default
    end
end
