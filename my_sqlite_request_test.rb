# calculator_test.rb

require 'test/unit'
require_relative 'my_sqlite_request'
require 'stringio'

class MySqliteRequestTest < Test::Unit::TestCase
  def setup
    @request = MySqliteRequest.new
    File.write('test_data.csv', "id,name,age\n1,John,25\n2,Jane,30\n3,Bob,22\n")
  end

  def test_select_query
    query = @request.from('test_data.csv').select(['name', 'age']).where('id', '2')
    stdout = $stdout
    $stdout = StringIO.new
    
    result = query.run

    expected_result = "Jane|30\n"
    assert_equal(expected_result, $stdout.string)
  end

  def test_select_query_with_star
    query = @request.from('test_data.csv').select(['*'])
    stdout = $stdout
    $stdout = StringIO.new
    
    result = query.run

    expected_result = "1|John|25\n" + "2|Jane|30\n" + "3|Bob|22\n"
    assert_equal(expected_result, $stdout.string)
  end

  def test_insert_query
    query = @request.insert('test_data.csv').values({'id' => '4', 'name' => 'Alice', 'age' => '28'})
    query.run

    result = CSV.read('test_data.csv', headers: true).map(&:to_h)
    expected_result = [
      {'id' => '1', 'name' => 'John', 'age' => '25'},
      {'id' => '2', 'name' => 'Jane', 'age' => '30'},
      {'id' => '3', 'name' => 'Bob', 'age' => '22'},
      {'id' => '4', 'name' => 'Alice', 'age' => '28'}
    ]
    assert_equal(expected_result, result)
  end

  def test_delete_query
    query = @request.from('test_data.csv').delete.where('id', '2')
    result = query.run

    result = CSV.read('test_data.csv', headers: true).map(&:to_h)

    expected_result = [
      {'id' => '1', 'name' => 'John', 'age' => '25'},
      {'id' => '3', 'name' => 'Bob', 'age' => '22'},
    ]
    assert_equal(expected_result, result)
  end

  def test_delete_query_without_where
    query = @request.from('test_data.csv').delete
    result = query.run

    result = CSV.read('test_data.csv', headers: true).map(&:to_h)

    expected_result = []
    assert_equal(expected_result, result)
  end

  def test_update_query
    query = @request.update('test_data.csv').set({'name' => 'Jane Updated'}).where('id', '2')
    result = query.run

    result = CSV.read('test_data.csv', headers: true).map(&:to_h)

    expected_result = [
      {'id' => '1', 'name' => 'John', 'age' => '25'},
      {'id' => '2', 'name' => 'Jane Updated', 'age' => '30'},
      {'id' => '3', 'name' => 'Bob', 'age' => '22'},
    ]

    assert_equal(expected_result, result)
  end

  def test_update_query_without_where
    query = @request.update('test_data.csv').set({'name' => 'All Updated'})
    result = query.run

    result = CSV.read('test_data.csv', headers: true).map(&:to_h)

    expected_result = [
      {'id' => '1', 'name' => 'All Updated', 'age' => '25'},
      {'id' => '2', 'name' => 'All Updated', 'age' => '30'},
      {'id' => '3', 'name' => 'All Updated', 'age' => '22'},
    ]

    assert_equal(expected_result, result)
  end

  def test_select_joins_query_no_where_clause
    File.write('joins_data.csv', "person_id,pet_name,pet_age,pet_type\n1,Woof,2,dog\n2,Kitty,7,tiger\n3,Smokey,15,bear\n")
    query = @request
        .from('test_data.csv')
        .select(['name', 'age', 'pet_name', 'pet_type'])
        .join('joins_data.csv', 'id', 'person_id')

    result = query.run

    expected_result = [
        {'name' => 'John', 'age' => '25', 'pet_name' => 'Woof', 'pet_type' => 'dog'},
        {'name' => 'Jane', 'age' => '30', 'pet_name' => 'Kitty', 'pet_type' => 'tiger'},
        {'name' => 'Bob', 'age' => '22', 'pet_name' => 'Smokey', 'pet_type' => 'bear'},
    ]
    assert_equal(expected_result, result)
  end


  def teardown
    File.delete('test_data.csv') if File.exist?('test_data.csv')
    File.delete('joins_data.csv') if File.exist?('joins_data.csv')
  end
end
