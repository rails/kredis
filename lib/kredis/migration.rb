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
    @redis.multi do
      keys.each { |key| migrate from: key, to: yield(key) }
    end
  end

  def migrate(from:, to:)
    @redis.evalsha @copy_sha, keys: [ from, Kredis.namespaced_key(to) ]
  end
end
