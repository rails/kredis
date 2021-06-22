class Kredis::CallbacksProxy
  attr_reader :type
  delegate :to_s, to: :type

  def initialize(type, record)
    @type, @record = type, record
  end

  def method_missing(method, *args, **kwargs, &block)
    @type.send(method, *args, **kwargs, &block)
  end
end
