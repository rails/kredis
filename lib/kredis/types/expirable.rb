module Kredis::Types::Expirable
  extend ActiveSupport::Concern

  included do
    proxying :expire, :expireat, :ttl

    attr_accessor :expires_in, :expires_at

    def expire_in(seconds)
      expire seconds.to_i
    end

    def expire_at(datetime)
      expireat datetime.to_i
    end
  end

  def self.on(*on_methods)
    Module.new do
      define_singleton_method :included do |type_klass|
        type_klass.include Kredis::Types::Expirable

        type_klass.prepend(Module.new do
          on_methods.each do |method|
            define_method method do |*args|
              super(*args)

              expire_in(@expires_in) if expires_in
              expire_at(@expires_at) if expires_at && !expires_in
            end
          end
        end)
      end
    end
  end
end


