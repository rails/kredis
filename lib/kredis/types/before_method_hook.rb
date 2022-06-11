module Kredis::Types::BeforeMethodHook
  def before_method(wrapper_method, *methods)
    prepend(@method_wrapper = Module.new) unless @method_wrapper
    methods.each do |method_name|
      @method_wrapper.send(:define_method, method_name) do |*args, **kwargs, &block|
        send wrapper_method
        super(*args, **kwargs, &block)
      end
    end
  end
end
