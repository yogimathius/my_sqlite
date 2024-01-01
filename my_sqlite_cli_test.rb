require 'test/unit'
require_relative 'my_sqlite_cli'

class TestMySqliteQueryCli < Test::Unit::TestCase
  def setup
    @cli = MySqliteQueryCli.new
    File.write('test_data.csv', "id,name,age\n1,John Doe,25\n2,Jane,30\n3,Bob,22\n")
  end

  def test_build_select
    query = "SELECT name, age FROM test_data.csv WHERE name = 'John Doe'"
    result = @cli.build_select(query)
    assert_equal(:select, result.instance_variable_get(:@type_of_request))
    assert_equal(["name", "age"], result.instance_variable_get(:@select_columns))
    assert_equal("test_data.csv", result.instance_variable_get(:@table_name))
    assert_equal([["name", "'John Doe'"]], result.instance_variable_get(:@where_params))
  end

  def test_build_update
    query = "UPDATE test_data.csv SET name = 'John Updated', age = '99' WHERE name = 'John Doe'"
    result = @cli.build_update(query)
    assert_equal(:update, result.instance_variable_get(:@type_of_request))
    assert_equal({"age"=>"99", "name"=>"John Updated"}, result.instance_variable_get(:@update_set_data))
    assert_equal("test_data.csv", result.instance_variable_get(:@table_name))
    assert_equal([["name", "'John Doe'"]], result.instance_variable_get(:@where_params))
  end

#   def test_parse_insert
#     query = "INSERT INTO nba_player_data_light.csv (column1, column2) VALUES (value1, value2);"
#     @cli.parse_insert(query)
#     assert_equal(["INSERT", "INTO", "table", "(column1,", "column2)"], @cli.instance_variable_get(:@insert_parts))
#     assert_equal(["VALUES", "value1", "value2"], @cli.instance_variable_get(:@insert_values))
#   end

#   def simulate_user_input(*inputs)
#     inputs.each do |input|
#       # Redefine gets to simulate user input
#       Kernel.send(:define_method, :gets) { "#{input}\n" }
  
#       # Run the CLI
#       @cli.run!
  
#       # Assert the state of your @cli object after each input
#     end
  
#     # Reset gets to its original definition
#     Kernel.send(:remove_method, :gets)
#   end

#   def simulate_stdin(*inputs, &block)
#     io = StringIO.new
#     inputs.flatten.each { |str| io.puts(str) }
#     io.rewind

#     actual_stdin, $stdin = $stdin, io
#     yield
#   ensure
#     $stdin = actual_stdin
#   end
  
#   def type_when_prompted(*list, &block)
#     $stdin.stub(:gets, proc { list.shift }, &block)
#   end
  
#   def test_run_with_input
#     # Use StringIO to simulate user input


#     # Redirect stdout temporarily to capture output
#     # output = StringIO.new
#     # $stdout = output

#     # Run the CLI
    
    
#     input = simulate_stdin("SELECT column1 FROM table WHERE condition;\nINSERT INTO table (column1) VALUES (value1);\nexit\n") {@cli.run!}
#     # Replace stdin temporarily
#     $stdin = input
#     # Reset stdin and stdout
#     $stdin = STDIN
#     $stdout = STDOUT

#     # Assert the captured output
#     expected_output = "insert_parts = [\"INSERT\", \"INTO\", \"table\", \"(column1)\"]\ninsert_parts = [\"value1\"]\n"
#     assert_equal(expected_output, output.string)
#   end
end