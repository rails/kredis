class Kredis::Types::CallbacksProxy
  attr_reader :type
  delegate :to_s, to: :type

  CALLBACK_OPERATIONS = {
    Kredis::Types::Counter => %i[ increment decrement reset ],
    Kredis::Types::Cycle => %i[ next ],
    Kredis::Types::Enum => %i[ value= reset ],
    Kredis::Types::Flag => %i[ mark remove ],
    Kredis::Types::Hash => %i[ update ],
    Kredis::Types::List => %i[ remove prepend append ],
    Kredis::Types::Scalar => %i[ value= clear ],
    Kredis::Types::Set => %i[ add remove replace take clear ],
    Kredis::Types::Slots => %i[ reserve release reset ]
  }

  def initialize(type, callback)
    @type, @callback = type, callback
  end

  def method_missing(method, *args, **kwargs, &block)
    result = type.send(method, *args, **kwargs, &block)

    if CALLBACK_OPERATIONS[type.class]&.include? method
      @callback.call(type)
    end

    result
  end
end
