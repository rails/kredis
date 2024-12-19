# frozen_string_literal: true

module Kredis::Namespace
  attr_accessor :global_namespace

  def namespace
    if global_namespace
      if value = thread_namespace
        "#{global_namespace}:#{value}"
      else
        global_namespace
      end
    else
      thread_namespace
    end
  end

  def thread_namespace
    Thread.current[:kredis_thread_namespace]
  end

  def thread_namespace=(value)
    Thread.current[:kredis_thread_namespace] = value
  end

  # Backward compatibility
  alias_method :namespace=, :thread_namespace=

  def namespaced_key(key)
    namespace ? "#{namespace}:#{key}" : key
  end
end
