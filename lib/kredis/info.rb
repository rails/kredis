# frozen_string_literal: true

module Kredis::Info
  def redis_version
    Gem::Version.new Kredis.redis.info("server")["redis_version"]
  end
end
