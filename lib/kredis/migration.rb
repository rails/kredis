require "active_support/core_ext/module/delegation"

class Kredis::Migration
  singleton_class.delegate :migrate_all, :migrate, :delete_all, to: :new

  def initialize(config = :shared)
    @redis = Kredis.configured_for config
    @copy_sha = @redis.script "load", "redis.call('SETNX', KEYS[2], redis.call('GET', KEYS[1])); return 1;"
  end

  def migrate_all(key_pattern)
    each_key_batch_matching(key_pattern) do |keys|
      keys.each do |key|
        ids = key.scan(/\d+/).map(&:to_i)
        migrate from: key, to: yield(key, *ids)
      end
    end
  end

  def migrate(from:, to:)
    to = Kredis.namespaced_key(to)

    if from != to
      log_migration "Migrating key #{from} to #{to}"
      @redis.evalsha @copy_sha, keys: [ from, to ]
    else
      log_migration "Skipping unaltered migration key #{from}"
    end
  end

  def delete_all(key_pattern)
    each_key_batch_matching(key_pattern) do |keys|
      @redis.del *keys
    end
  end

  private
    SCAN_BATCH_SIZE = 1_000

    def each_key_batch_matching(key_pattern, &block)
      cursor = "0"
      begin
        cursor, keys = @redis.scan(cursor, match: key_pattern, count: SCAN_BATCH_SIZE)
        @redis.multi { yield keys }
      end until cursor == "0"
    end

    def log_migration(message)
      Kredis.logger&.debug "[Kredis Migration] #{message}"
    end
end
