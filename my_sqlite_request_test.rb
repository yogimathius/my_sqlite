# calculator_test.rb

require 'test/unit'
require_relative 'my_sqlite_request'

class MySqliteRequestTest < Test::Unit::TestCase
  def setup
    @request = MySqliteRequest.new
    File.write('test_data.csv', "id,name,age\n1,John,25\n2,Jane,30\n3,Bob,22\n")
  end

  def test_select_query
    query = @request.from('test_data.csv').select(['name', 'age']).where('id', '2')
    result = query.run

    expected_result = [{'name' => 'Jane', 'age' => '30'}]
    assert_equal(expected_result, result)
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

  def teardown
    File.delete('test_data.csv') if File.exist?('test_data.csv')
  end
end
