require "test_helper"

class CallbacksTest < ActiveSupport::TestCase
  test "list with after_change proc callback" do
    person_mock = Minitest::Mock.new
    proc_mock = Minitest::Mock.new

    Person.stub :new, person_mock do
      person = Person.new
      person_mock.expect(:names_with_after_change_proc_callback, Kredis::CallbacksProxy.new(Kredis.list("person:8:names"), person, proc_mock))
      proc_mock.expect(:call, nil, [person])
      person.names_with_after_change_proc_callback.append(%w[ david kasper ])
    end

    assert_mock person_mock
    assert_mock proc_mock
  end

  test "list with after_change method callback" do
    person_mock = Minitest::Mock.new

    Person.stub :new, person_mock do
      person = Person.new
      person_mock.expect(:names_with_after_change_method_callback, Kredis::CallbacksProxy.new(Kredis.list("person:8:names"), person, :changed))
      person_mock.expect(:changed, nil, [person])
      person.names_with_after_change_method_callback.append(%w[ david kasper ])
    end

    assert_mock person_mock
  end
end
