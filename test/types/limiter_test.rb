# frozen_string_literal: true

require "test_helper"

class LimiterTest < ActiveSupport::TestCase
  setup { @limiter = Kredis.limiter "mylimit", limit: 5 }

  test "exceeded after limit is reached" do
    4.times do
      @limiter.poke
      assert_not @limiter.exceeded?
    end

    @limiter.poke
    assert @limiter.exceeded?
  end

  test "never exceeded when redis is down" do
    stub_redis_down(@limiter) do
      10.times do
        @limiter.poke
        assert_not @limiter.exceeded?
      end
    end
  end
end
