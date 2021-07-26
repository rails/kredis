require "active_support/log_subscriber"

class Kredis::LogSubscriber < ActiveSupport::LogSubscriber
  def proxy(event)
    prefix = color("Kredis #{event.payload[:type]} (#{event.duration.round(1)}ms)", YELLOW, true)
    debug "  #{prefix}  #{color(event.payload[:message], YELLOW, true)}"
  end

  def migration(event)
    prefix = color("Kredis Migration (#{event.duration.round(1)}ms)", YELLOW, true)
    debug "  #{prefix}  #{color(event.payload[:message], YELLOW, true)}"
  end

  def meta(event)
    prefix = color("Kredis (#{event.duration.round(1)}ms)", MAGENTA, true)
    info "  #{prefix}  #{color(event.payload[:message], MAGENTA, true)}"
  end
end

Kredis::LogSubscriber.attach_to :kredis
