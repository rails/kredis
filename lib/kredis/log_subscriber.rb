# frozen_string_literal: true

require "active_support/log_subscriber"

class Kredis::LogSubscriber < ActiveSupport::LogSubscriber
  def proxy(event)
    debug formatted_in(YELLOW, event, type: "Proxy")
  end

  def migration(event)
    debug formatted_in(YELLOW, event, type: "Migration")
  end

  def meta(event)
    info formatted_in(MAGENTA, event)
  end

  private
    def formatted_in(color, event, type: nil)
      color "  Kredis #{type} (#{event.duration.round(1)}ms)  #{event.payload[:message]}", color, bold: true
    end
end

Kredis::LogSubscriber.attach_to :kredis
