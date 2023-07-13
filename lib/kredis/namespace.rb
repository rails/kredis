# frozen_string_literal: true

module Kredis::Namespace
  def namespace=(namespace)
    Thread.current[:kredis_namespace] = namespace
  end

  def namespace
    Thread.current[:kredis_namespace]
  end

  def namespaced_key(key)
    namespace ? "#{namespace}:#{key}" : key
  end
end
