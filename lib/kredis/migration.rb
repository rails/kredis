class Kredis::Migration
  def self.configured_for(config)
    new Kredis.configured_for config
  end

  def initialize(redis)
    @redis = redis
    @copy_sha = redis.script "load", "redis.call('SETNX', KEYS[2], redis.call('GET', KEYS[1])); return 1;"
  end

  def migrate_all(key_matcher)
    keys = @redis.keys(key_matcher)
    log_migration "Found #{keys.size} keys using #{key_matcher}"

    @redis.multi do
      keys.each { |key| migrate from: key, to: yield(key) }
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

  private
    def log_migration(message)
      Kredis.logger&.debug "[Kredis Migration] #{message}"
    end
end
