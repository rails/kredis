# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

class Kredis::Migration
  singleton_class.delegate :migrate_all, :migrate, :delete_all, to: :new

  def initialize(config = :shared)
    @redis = Kredis.configured_for config
    # TODO: Replace script loading with `copy` command once Redis 6.2+ is the minimum supported version.
    @copy_sha = @redis.script "load", "redis.call('SETNX', KEYS[2], redis.call('GET', KEYS[1])); return 1;"
  end

  def migrate_all(key_pattern)
    each_key_batch_matching(key_pattern) do |keys, pipeline|
      keys.each do |key|
        ids = key.scan(/\d+/).map(&:to_i)
        migrate from: key, to: yield(key, *ids), pipeline: pipeline
      end
    end
  end

  def migrate(from:, to:, pipeline: nil)
    namespaced_to = Kredis.namespaced_key(to)

    if to.present? && from != namespaced_to
      log_migration "Migrating key #{from} to #{namespaced_to}" do
        (pipeline || @redis).evalsha @copy_sha, keys: [ from, namespaced_to ]
      end
    else
      log_migration "Skipping blank/unaltered migration key #{from} → #{to}"
    end
  end

  def delete_all(*key_patterns)
    log_migration "DELETE ALL #{key_patterns.inspect}" do
      if key_patterns.length > 1
        @redis.del(*key_patterns)
      else
        each_key_batch_matching(key_patterns.first) do |keys, pipeline|
          pipeline.del(*keys)
        end
      end
    end
  end

  private
    SCAN_BATCH_SIZE = 1_000

    def each_key_batch_matching(key_pattern, &block)
      cursor = "0"
      begin
        cursor, keys = @redis.scan(cursor, match: key_pattern, count: SCAN_BATCH_SIZE)
        @redis.multi { |pipeline| yield keys, pipeline }
      end until cursor == "0"
    end

    def log_migration(message, &block)
      Kredis.instrument :migration, message: message, &block
    end
end
