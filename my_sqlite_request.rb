require 'csv'

class MySqliteRequest
  def initialize
    @table_data = nil
    @selected_column = nil
    @where_column = nil
    @where_criteria = nil
    @join_column_db_a = nil
    @join_filename_db_b = nil
    @join_column_db_b = nil
    @order_type = nil
    @order_column = nil
    @insert_table_name = nil
    @insert_values = nil
    @update_table_name = nil
    @update_set_data = nil
  end

  def from(table_name)
    @table_data = CSV.read(table_name, headers: true)
    self
  end

  def select(column_name)
    @selected_column = column_name
    self
  end

  def where(column_name, criteria)
    @where_column = column_name
    @where_criteria = criteria
    self
  end

  def join(column_on_db_a, filename_db_b, column_on_db_b)
    @join_column_db_a = column_on_db_a
    @join_filename_db_b = filename_db_b
    @join_column_db_b = column_on_db_b
    self
  end

  def order(order_type, column_name)
    @order_type = order_type
    @order_column = column_name
    self
  end

  def insert(table_name)
    @insert_table_name = table_name
    self
  end

  def values(data)
    @insert_values = data
    self
  end

  def update(table_name)
    @update_table_name = table_name
    self
  end

  def set(data)
    @update_set_data = data
    self
  end

  def delete
  end

  # def to_s
  #   "Table Data: #{@table_data}\nSelected Column: #{@selected_column}\nWhere Column: #{@where_column}\nWhere Criteria: #{@where_criteria}\nJoin Column DB A: #{@join_column_db_a}\nJoin Filename DB B: #{@join_filename_db_b}\nJoin Column DB B: #{@join_column_db_b}\nOrder Type: #{@order_type}\nOrder Column: #{@order_column}\nInsert Table Name: #{@insert_table_name}\nInsert Values: #{@insert_values}\nUpdate Table Name: #{@update_table_name}\nUpdate Set Data: #{@update_set_data}"
  # end
end

# Example usage:
request = MySqliteRequest.new
request = request.from('nba_player_data.csv')
puts request

request = request.select('name')
request = request.where('team', 'Lakers')
puts request
request = request.join('player_id', 'teams.csv', 'team_id')
request = request.order('asc', 'points')
puts request
request = request.insert('new_players')
request = request.values({ 'name' => 'LeBron James', 'team' => 'Lakers', 'points' => 25 })
puts request
request = request.update('player_data')
request = request.set({ 'points' => 30 })

puts request
