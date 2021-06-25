require "test_helper"

def with_mocked_record
  person_mock = Minitest::Mock.new

  Person.stub :new, person_mock do
    person = Person.new
    yield person_mock, person

    assert_mock person_mock
  end
end

def with_mocked_proc
  proc_mock = Minitest::Mock.new

  yield proc_mock

  assert_mock proc_mock
end

class CallbacksTest < ActiveSupport::TestCase
  setup { @person_mock = Minitest::Mock.new }

  test "list with after_change proc callback" do
    with_mocked_proc do |proc_mock|
      with_mocked_record do |person_mock, person|
        names = Kredis.list("person:8:names")
        person_mock.expect(:names, Kredis::CallbacksProxy.new(names, person, proc_mock))
        proc_mock.expect(:call, nil, [person, names])

        person.names.append(%w[ david kasper ])
      end
    end
  end

  test "list with after_change method callback" do
    with_mocked_record do |person_mock, person|
      names = Kredis.list("person:8:names")
      person_mock.expect(:names, Kredis::CallbacksProxy.new(names, person, :changed))
      person_mock.expect(:changed, nil, [person, names])

      person.names.append(%w[ david kasper ])
    end
  end

  test "flag with after_change proc callback" do
    with_mocked_proc do |proc_mock|
      with_mocked_record do |person_mock, person|
        special = Kredis.flag("person:8:special")
        person_mock.expect(:special, Kredis::CallbacksProxy.new(special, person, proc_mock))
        proc_mock.expect(:call, nil, [person, special])

        person.special.mark
      end
    end
  end

  test "flag with after_change method callback" do
    with_mocked_record do |person_mock, person|
      special = Kredis.flag("person:8:special")
      person_mock.expect(:special, Kredis::CallbacksProxy.new(special, person, :changed))
      person_mock.expect(:changed, nil, [person, special])

      person.special.mark
    end
  end

  test "string with after_change proc callback" do
    with_mocked_proc do |proc_mock|
      with_mocked_record do |person_mock, person|
        address = Kredis.string("person:8:address")
        person_mock.expect(:address, Kredis::CallbacksProxy.new(address, person, proc_mock))
        proc_mock.expect(:call, nil, [person, address])

        person.address.value = "Copenhagen"
      end
    end
  end

  test "string with after_change method callback" do
    with_mocked_record do |person_mock, person|
      address = Kredis.string("person:8:address")
      person_mock.expect(:address, Kredis::CallbacksProxy.new(address, person, :changed))
      person_mock.expect(:changed, nil, [person, address])

      person.address.value = "Copenhagen"
    end
  end

  test "slot with after_change proc callback" do
    with_mocked_proc do |proc_mock|
      with_mocked_record do |person_mock, person|
        attention = Kredis.slot("person:8:attention")
        person_mock.expect(:attention, Kredis::CallbacksProxy.new(attention, person, proc_mock))
        proc_mock.expect(:call, nil, [person, attention])

        person.attention.reserve
      end
    end
  end

  test "slot with after_change method callback" do
    with_mocked_record do |person_mock, person|
      attention = Kredis.slot("person:8:attention")
      person_mock.expect(:attention, Kredis::CallbacksProxy.new(attention, person, :changed))
      person_mock.expect(:changed, nil, [person, attention])

      person.attention.reserve
    end
  end

  test "enum with after_change proc callback" do
    with_mocked_proc do |proc_mock|
      with_mocked_record do |person_mock, person|
        morning = Kredis.enum("person:8:morning", values: %w[ bright blue black ], default: "bright")
        person_mock.expect(:morning, Kredis::CallbacksProxy.new(morning, person, proc_mock))
        proc_mock.expect(:call, nil, [person, morning])

        person.morning.value = "blue"
      end
    end
  end

  test "enum with after_change method callback" do
    with_mocked_record do |person_mock, person|
      morning = Kredis.enum("person:8:morning", values: %w[ bright blue black ], default: "bright")
      person_mock.expect(:morning, Kredis::CallbacksProxy.new(morning, person, :changed))
      person_mock.expect(:changed, nil, [person, morning])

      person.morning.value = "blue"
    end
  end

  test "set with after_change proc callback" do
    with_mocked_proc do |proc_mock|
      with_mocked_record do |person_mock, person|
        vacations = Kredis.set("person:8:vacations")
        person_mock.expect(:vacations, Kredis::CallbacksProxy.new(vacations, person, proc_mock))
        proc_mock.expect(:call, nil, [person, vacations])

        person.vacations.add "paris"
      end
    end
  end

  test "set with after_change method callback" do
    with_mocked_record do |person_mock, person|
      vacations = Kredis.set("person:8:vacations")
      person_mock.expect(:vacations, Kredis::CallbacksProxy.new(vacations, person, :changed))
      person_mock.expect(:changed, nil, [person, vacations])

      person.vacations.add "paris"
    end
  end

  test "json with after_change proc callback" do
    with_mocked_proc do |proc_mock|
      with_mocked_record do |person_mock, person|
        settings = Kredis.json("person:8:settings")
        person_mock.expect(:settings, Kredis::CallbacksProxy.new(settings, person, proc_mock))
        proc_mock.expect(:call, nil, [person, settings])

        person.settings.value = { "color" => "red", "count" => 2 }
      end
    end
  end

  test "json with after_change method callback" do
    with_mocked_record do |person_mock, person|
      settings = Kredis.json("person:8:settings")
      person_mock.expect(:settings, Kredis::CallbacksProxy.new(settings, person, :changed))
      person_mock.expect(:changed, nil, [person, settings])

      person.settings.value = { "color" => "red", "count" => 2 }
    end
  end

  test "counter with after_change proc callback" do
    with_mocked_proc do |proc_mock|
      with_mocked_record do |person_mock, person|
        amount = Kredis.counter("person:8:amount")
        person_mock.expect(:amount, Kredis::CallbacksProxy.new(amount, person, proc_mock))
        proc_mock.expect(:call, nil, [person, amount])

        person.amount.increment
      end
    end
  end

  test "counter with after_change method callback" do
    with_mocked_record do |person_mock, person|
      amount = Kredis.counter("person:8:amount")
      person_mock.expect(:amount, Kredis::CallbacksProxy.new(amount, person, :changed))
      person_mock.expect(:changed, nil, [person, amount])

      person.amount.increment
    end
  end
end
