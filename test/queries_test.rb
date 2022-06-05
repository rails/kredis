require "test_helper"

class QueriesTest < ActiveSupport::TestCase
  teardown do
    Kredis.namespace = nil
  end

  test "search keys" do
    insert_keys

    should_find_keys = 5.times.map{|i| "mykey:#{i}"}
    found_keys = []
    
    Kredis.search('mykey:*'){ |keys| found_keys += keys }
    
    assert_equal should_find_keys.sort, found_keys.sort
  end

  test "search keys with different batch size" do   
    insert_keys

    keys_count = 0
    
    Kredis.search('mykey:*', batch_size: 3){ |keys| keys_count += keys.size }

    assert_equal 5, keys_count    
  end

  test "search keys with namespace" do
    insert_keys('mynamespace')

    should_find_keys = 5.times.map{|i| "mynamespace:mykey:#{i}"}
    found_keys = []
    
    Kredis.search('mykey:*'){ |keys| found_keys += keys }
    
    assert_equal should_find_keys.sort, found_keys.sort
  end

  test "search keys with different config" do
    # Config cannot be tested in this test suite so 
    # for now checking if using the keyword argument passes
    Kredis.search('mykey:*', config: :secondary) { }
  end

  private

  def insert_keys(namespace = nil)
    Kredis.namespace = namespace

    5.times { |i| Kredis.string("mykey:#{i}").value = "1" }
  end

end
