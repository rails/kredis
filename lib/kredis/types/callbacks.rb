module Kredis::Types::Callbacks
  extend ActiveSupport::Concern
  include ActiveSupport::Callbacks

  included do
    define_callbacks :change

    set_callback :change, :after do |object|
      @changed_callback&.call(object)
    end
  end

  def initialize(redis, key, changed: ->(set){}, **options)
    super redis, key, **options

    @changed_callback = changed
  end
end
