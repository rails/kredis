module Kredis::Types::Proxying::AfterChange
  extend ActiveSupport::Concern

  class_methods do
    def invoke_after_change_on(*methods)
      after_change_methods_module.module_eval do
        methods.each do |method|
          define_method method do |*args, **kwargs, &block|
            result = super(*args, **kwargs, &block)
            invoke_after_change # Can't use `tap` since `super` can return a `Redis::Future`.
            result
          end
        end
      end
    end

    def after_change_methods_module
      @after_change_methods_module ||= const_set(:AfterChangeMethods, Module.new).tap { |mod| prepend mod }
    end
  end

  def initialize(*args, after_change: nil, **kwargs)
    super(*args, **kwargs)
    @after_change = after_change
  end

  private
    def invoke_after_change
      @after_change&.call(self)
    end
end
