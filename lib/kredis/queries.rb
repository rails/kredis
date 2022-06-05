module Kredis::Queries
  def search(key_pattern, batch_size: 1000, config: :shared, &block)
    pattern = namespace ? "#{namespace}:#{key_pattern}" : key_pattern
    cursor = "0"
    begin
      cursor, keys = redis(config: config).scan(cursor, match: pattern, count: batch_size)
      redis.multi { |pipeline| yield keys, pipeline }
    end until cursor == "0"
  end
end
