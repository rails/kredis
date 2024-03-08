# frozen_string_literal: true

module Kredis::Info
  def redis_version
    redis_versions.first
  end

  def redis_versions
    Array.wrap(Kredis.redis.info("server")).tap do |versions|
      versions.map! { |v| v["redis_version"] }
      versions.map! { |v| Gem::Version.new(v) }
    end
  end
end
