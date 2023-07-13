# frozen_string_literal: true

class Kredis::Types::CallbacksProxy
  attr_reader :type
  delegate :to_s, to: :type

  AFTER_CHANGE_OPERATIONS = {
    Kredis::Types::Counter => %i[ increment decrement reset ],
    Kredis::Types::Cycle => %i[ next reset ],
    Kredis::Types::Enum => %i[ value= reset ],
    Kredis::Types::Flag => %i[ mark remove ],
    Kredis::Types::Hash => %i[ update delete []= remove ],
    Kredis::Types::List => %i[ remove prepend append << ],
    Kredis::Types::Scalar => %i[ value= clear ],
    Kredis::Types::Set => %i[ add << remove replace take clear ],
    Kredis::Types::Slots => %i[ reserve release reset ],
    Kredis::Types::UniqueList => %i[ remove prepend append << ]
  }

  def initialize(type, callback)
    @type, @callback = type, callback
  end

  def method_missing(method, *args, **kwargs, &block)
    result = type.send(method, *args, **kwargs, &block)
    invoke_suitable_after_change_callback_for method
    result
  end

  private
    def invoke_suitable_after_change_callback_for(method)
      @callback.call(type) if AFTER_CHANGE_OPERATIONS[type.class]&.include? method
    end
end
