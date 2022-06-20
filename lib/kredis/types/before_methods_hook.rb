module Kredis::Types::BeforeMethodsHook
  def before_methods(*methods, invoke:)
    prepend(@method_wrapper = Module.new) unless @method_wrapper
    methods.each do |method_name|
      @method_wrapper.send(:define_method, method_name) do |*args, **kwargs, &block|
        send invoke
        super(*args, **kwargs, &block)
      end
    end
  end
end
