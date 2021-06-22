class Kredis::CallbacksProxy
  attr_reader :type
  delegate :to_s, to: :type

  def initialize(type, record, callback)
    @type, @record, @callback = type, record, callback
  end

  def method_missing(method, *args, **kwargs, &block)
    result = @type.send(method, *args, **kwargs, &block)

    if @type.callback_operations.include? method
      case @callback
      when Symbol then @record.send(@callback, @record)
      when Proc then @callback.call(@record)
      end
    end

    result
  end
end
