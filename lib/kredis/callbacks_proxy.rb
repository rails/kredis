class Kredis::CallbacksProxy
  attr_reader :type
  delegate :to_s, to: :type

  def initialize(type, record, callback)
    @type, @record, @callback = type, record, callback
  end

  def method_missing(method, *args, **kwargs, &block)
    result = @type.send(method, *args, **kwargs, &block)

    if @type.callback_operations&.include? method
      if @callback.respond_to? :call
        @callback.call(@record, @type)
      elsif @callback.is_a? Symbol
        @record.send(@callback, @record, @type)
      end
    end

    result
  end
end
