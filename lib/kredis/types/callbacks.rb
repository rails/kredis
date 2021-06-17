module Kredis::Types::Callbacks
  extend ActiveSupport::Concern

  module ClassMethods
    def runs_callbacks_for(*method_names)
      self.method_names = method_names
    end
  end

  def self.prepended(base)
    base.include ActiveSupport::Callbacks
    base.cattr_accessor :method_names
    base.define_callbacks :change

    base.set_callback :change, :after do |object|
      @changed_callback&.call(object)
    end
  end

  def initialize(*args, **kwargs)
    super(*args, **kwargs.except(:changed))

    @changed_callback = kwargs[:changed]

    singleton_class.class_eval do
      method_names.each do |method_name|
        define_method method_name do |*args, **kwargs|
          run_callbacks :change do
            super *args, **kwargs
          end
        end
      end
    end
  end
end
