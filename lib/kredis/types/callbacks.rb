module Kredis::Types::Callbacks
  extend ActiveSupport::Concern

  def initialize(redis, key, changed: ->(set){}, **options)
    super redis, key, **options

    @changed_callback = changed
  end
end
