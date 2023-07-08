module Kredis::DefaultValues
  extend ActiveSupport::Concern

  prepended do
    attr_writer :default

    def default
      case @default
      when Proc   then @default.call
      when Symbol then send(@default)
      else @default
      end
    end

    private
      def set_default
        raise NotImplementedError, "Kredis type #{self.class} needs to define #set_default"
      end
  end

  def initialize(...)
    super

    if default.present? && !exists?
      set_default
    end
  end
end
