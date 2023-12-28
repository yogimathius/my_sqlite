=begin
Part I Describing scope of project
# SELECT QUERY
# INSERT QUERY
# UPDATE QUERY
# DELETE QUERY

#1 Type of request
#2 Set variable settings
#3 Run
=end

require 'csv'

class MySqliteRequest
  def initialize
    @type_of_request    = :none
    @select_columns     = []
    @where_params       = []
    @insert_attributes  = []
    @update_attributes  = []
    @table_name         = nil
    @order              = :asc
    # @selected_column = nil
    # @where_column = nil
    # @where_criteria = nil
    # @join_column_db_a = nil
    # @join_filename_db_b = nil
    # @join_column_db_b = nil
    # @order_type = nil
    # @order_column = nil
    # @insert_table_name = nil
    # @insert_values = nil
    # @update_table_name = nil
    # @update_set_data = nil
  end

  def from(table_name)
    @table_name = table_name
    # @table_data = CSV.read(table_name, headers: true)
    self
  end

  def select(columns)
    if (columns.is_a?(Array))
        @select_columns += columns.collect { |elem| elem.to_s }
    else 
        @select_columns << columns.to_s
    end
    self._setTypeOfRequest(:select)
    # @selected_column = column_name
    self
  end

  def where(column_name, criteria)
    @where_params << [column_name, criteria]
    # @where_column = column_name
    # @where_criteria = criteria
    self
  end

  def join(column_on_db_a, filename_db_b, column_on_db_b)
    @join_column_db_a = column_on_db_a
    @join_filename_db_b = filename_db_b
    @join_column_db_b = column_on_db_b
    self
  end

  def order(order_type, column_name)
    @order = order_type
    @order_column = column_name
    self
  end

  def insert(table_name)
    self._setTypeOfRequest(:insert)
    @table_name = table_name
    # @insert_table_name = table_name
    self
  end

  def values(data)
    if (@type_of_request == :insert)
        @insert_attributes = data
    else
        raise 'Wrong type of request to call values()'
    end
    self
  end

  def update(table_name)
    self._setTypeOfRequest(:update)
    @table_name = table_name
    # @update_table_name = table_name
    self
  end

  def set(data)
    @update_set_data = data
    self
  end

  def delete
    self._setTypeOfRequest(:delete)
    self
  end

  def print_select_type
    puts "Select Attributes #{@select_columns}"
    puts "Where Attributes #{@where_params}"
  end

  def print_insert_type
    puts "Inset Attributes #{@insert_attributes}"
    # puts "Where Attributes #{@where_params}"
  end

  def print_delete_type
    puts "Where Attributes #{@where_params}"
  end

  def print
    puts "Type of Request #{@type_of_request}"
    puts "Table Name #{@table_name}"
    if (@type_of_request == :select)
        print_select_type
    elsif (@type_of_request == :insert)
        print_insert_type
    elsif (@type_of_request == :delete)
        print_delete_type
    end
  end

  def run
    print
    if (@type_of_request == :select)
        _run_select
    elsif (@type_of_request == :insert)
        _run_insert
    elsif (@type_of_request == :delete)
        _run_delete
    end
    # have to bulid private methods, for each CLAUSE, to manipulate data based on query request
  end
  # def to_s
  #   "Table Data: #{@table_data}\nSelected Column: #{@selected_column}\nWhere Column: #{@where_column}\nWhere Criteria: #{@where_criteria}\nJoin Column DB A: #{@join_column_db_a}\nJoin Filename DB B: #{@join_filename_db_b}\nJoin Column DB B: #{@join_column_db_b}\nOrder Type: #{@order_type}\nOrder Column: #{@order_column}\nInsert Table Name: #{@insert_table_name}\nInsert Values: #{@insert_values}\nUpdate Table Name: #{@update_table_name}\nUpdate Set Data: #{@update_set_data}"
  # end

  private

  def _run_select
    result = []
    CSV.parse(File.read(@table_name), headers: true).each do |row|
        @where_params.each do |where_attribute|
            if row[where_attribute[0]] == where_attribute[1]
                result << row.to_hash.slice(*@select_columns)
            end
        end
    end
    result
  end

  def _run_insert
    File.open(@table_name, 'a') do |f|
        f.puts @insert_attributes.values.join(',')
    end
  end

  def _run_delete
    csv = CSV.read(@table_name, headers: true)
    @where_params.each do |where_attribute|
        csv.delete_if do |row|
            row[where_attribute[0]] == where_attribute[1]
        end
    end
    
    File.open(@table_name, 'w') do |csv_file|
        csv_file << csv.headers
        csv.each do |row|
            csv_file << row
        end
    end
  end

  def _setTypeOfRequest(new_type)
    if (@type_of_request == :none or @type_of_request == new_type)
        @type_of_request = new_type
    else
        raise "Invalid: type of request already set to #{@type_of_request} (new_type => #{@new_type})"
    end
  end

end

def _main()
=begin
    # testing select query
    request = MySqliteRequest.new
    request = request.from('nba_player_data.csv')
    request = request.select('name')
    request = request.where('year_start', '1991')
    p request.run.count
=end

=begin
    # testing insert query
    request = MySqliteRequest.new
    request = request.insert('nba_player_data_test.csv')
    request = request.values({"name" => "Bud Acton", "year_start" => "1968", "year_end" => "1968", "position" => "F", "height" => "6-6" , "weight" => "210", "birth_date" => "January 11, 1942", "college" => "Hillsdale College"
})
    request = request.where('year_start', '1991')
    request = 
    request.run
=end

    # testing delete query
    request = MySqliteRequest.new
    request = request.from('nba_player_data_test.csv')
    request = request.delete
    request = request.where('college', 'Duke University')
    request.run

end

_main()

# "name" => "Bud Acton", "year_start" => "1968", "year_end" => "1968", "position" => "F", "height" => "6-6" , "weight" => "210", "birth_date" => "January 11, 1942", "college" => "Hillsdale College"


# Example usage:
# request = MySqliteRequest.new
# request = request.from('nba_player_data.csv')
# puts request

# request = request.select('name')
# request = request.where('team', 'Lakers')
# puts request
# request = request.join('player_id', 'teams.csv', 'team_id')
# request = request.order('asc', 'points')
# puts request
# request = request.insert('new_players')
# request = request.values({ 'name' => 'LeBron James', 'team' => 'Lakers', 'points' => 25 })
# puts request
# request = request.update('player_data')
# request = request.set({ 'points' => 30 })

# puts request
