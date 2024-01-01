require 'test/unit'
require_relative 'my_sqlite_cli'

class TestMySqliteQueryCli < Test::Unit::TestCase
  def setup
    @cli = MySqliteQueryCli.new
    File.write('test_data.csv', "id,name,age\n1,John Doe,25\n2,Jane,30\n3,Bob,22\n")
  end

  def test_build_select
    query = "SELECT name, age FROM test_data.csv WHERE name = 'John Doe'"
    result = @cli.parse(query)
    assert_equal(:select, result.instance_variable_get(:@type_of_request))
    assert_equal(["name", "age"], result.instance_variable_get(:@select_columns))
    assert_equal("test_data.csv", result.instance_variable_get(:@table_name))
    assert_equal([["name", "John Doe"]], result.instance_variable_get(:@where_params))
  end

  def test_build_update
    query = "UPDATE test_data.csv SET name = 'John Updated', age = '99' WHERE name = 'John Doe'"
    result = @cli.parse(query)
    assert_equal(:update, result.instance_variable_get(:@type_of_request))
    assert_equal({"age"=>"99", "name"=>"John Updated"}, result.instance_variable_get(:@update_set_data))
    assert_equal("test_data.csv", result.instance_variable_get(:@table_name))
    assert_equal([["name", "John Doe"]], result.instance_variable_get(:@where_params))
  end

  def test_build_insert
    query = "INSERT INTO test_data.csv VALUES (value1, value2, value3);"
    result = @cli.parse(query)
    assert_equal(:insert, result.instance_variable_get(:@type_of_request))
    assert_equal("test_data.csv", result.instance_variable_get(:@table_name))
    assert_equal(["value1", "value2", "value3"], result.instance_variable_get(:@insert_attributes))
  end

  def test_build_delete
    query = "DELETE FROM test_data.csv WHERE name = 'John Doe';"
    result = @cli.parse(query)
    assert_equal(:delete, result.instance_variable_get(:@type_of_request))
    assert_equal("test_data.csv", result.instance_variable_get(:@table_name))
    assert_equal([["name", "John Doe"]], result.instance_variable_get(:@where_params))
  end

  def teardown
    File.delete('test_data.csv') if File.exist?('test_data.csv')
    # File.delete('joins_data.csv') if File.exist?('joins_data.csv')
  end
end