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
    @join_attributes    = {}
    @insert_attributes  = []
    @update_attributes  = []
    @table_name         = nil
    @order              = :asc
  end

  def from(table_name)
    @table_name = table_name
    self
  end

  def select(columns)
    if columns.is_a?(Array)
        @select_columns += columns.collect { |elem| elem.to_s }
    else 
        @select_columns << columns.to_s
    end
    self._setTypeOfRequest(:select)
    self
  end

  def where(column_name, criteria)
    @where_params << [column_name, criteria]
    self
  end

  def join(filename_db_b, column_on_db_a,  column_on_db_b)
    @join_attributes = {
        filename_db_b: filename_db_b,
        column_on_db_a: column_on_db_a,
        column_on_db_b: column_on_db_b
    }
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
    self
  end

  def values(data)
    if @type_of_request == :insert
        @insert_attributes = data
    else
        raise 'Wrong type of request to call values()'
    end
    self
  end

  def update(table_name)
    self._setTypeOfRequest(:update)
    @table_name = table_name
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
    puts "Insert Attributes #{@insert_attributes}"
  end

  def print_delete_type
    puts "Where Attributes #{@where_params}"
  end
    
  def print_update_type
    puts "Update Set Data #{@update_set_data}"
    puts "Where Attributes #{@where_params}"
  end

  def print
    puts "Type of Request #{@type_of_request}"
    puts "Table Name #{@table_name}"
    if @type_of_request == :select
        print_select_type
    elsif @type_of_request == :insert
        print_insert_type
    elsif @type_of_request == :delete
        print_delete_type
    elsif @type_of_request == :update
        print_update_type
    end
  end

  def run
    # print
    if @type_of_request == :select
        _run_select
    elsif @type_of_request == :insert
        _run_insert
    elsif @type_of_request == :delete
        _run_delete
    elsif @type_of_request == :update
        _run_update
    end
  end

  private

  def _run_select
    result = []
    CSV.parse(File.read(@table_name), headers: true).each do |row|
        _run_join(row) unless @join_attributes.empty?

        selected_columns = if @select_columns[0] != "*"
            row.to_hash.slice(*@select_columns).values.join("|")
        else
            row.to_s.split(",").join("|")
        end

        if @where_params.any?
            @where_params.each do |where_attribute|
                if row[where_attribute[0]] == where_attribute[1]
                    result << selected_columns
                end
            end
        else 
            result << selected_columns
        end
    end

    puts result.join
  end

  def _run_insert
    File.open(@table_name, 'a') do |f|
        f.puts @insert_attributes.values.join(',')
    end
  end

  def _run_delete
    csv = CSV.read(@table_name, headers: true)
    
    csv.delete_if do |row|
        @where_params.any? ? @where_params.any? { |where_attribute| row[where_attribute[0]] == where_attribute[1] } : true
    end
    File.open(@table_name, 'w') { |f| f.puts(csv) }
  end

  def _run_update
    csv = CSV.read(@table_name, headers: true)
    csv.each do |row|
        if @where_params.any?
          @where_params.each do |where_attribute|
            next unless row[where_attribute[0]] == where_attribute[1]
      
            @update_set_data.each do |update_key, update_value|
              row[update_key] = update_value
            end
          end
        else
          @update_set_data.each do |update_key, update_value|
            row[update_key] = update_value
          end
        end
      end
    File.open(@table_name, 'w') { |f| f.puts(csv) }
  end

  def _run_join(row)
    CSV.parse(File.read(@join_attributes[:filename_db_b]), headers: true).each do |join_row|
        if row[@join_attributes[:column_on_db_a]] == join_row[@join_attributes[:column_on_db_b]]
            join_row.each do |key_value|
                row.push(key_value)
            end
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

# request = MySqliteRequest.new

# ===== testing select query =====
# request = request.from('nba_player_data.csv')
# request = request.select('name')
# request = request.where('year_start', '1991') # can be called optionally
# p request.run

# ===== testing select with join query =====
# request = request
#     .from('nba_player_data_light.csv')
#     .select(['name', 'weight', 'collage', 'birth_city'])
#     .join('nba_players_light.csv', 'name', 'player')

# request.run.each do |player|
#     p player
# end

# ===== testing insert query ======
# request = request.insert('nba_player_data_light.csv')
# request = request.values({
#     "name" => "Bud Acton",
#     "year_start" => "1968",
#     "year_end" => "1968",
#     "position" => "F",
#     "height" => "6-6" ,
#     "weight" => "210",
#     "birth_date" => "January 11, 1942",
#     "college" => "Hillsdale College"
# })
# request = request.where('year_start', '1991')
# request = 
# request.run

# ===== testing update query =====
# request = request.update('nba_player_data_light.csv')
# request = request.set({"name" => "Bud Updated", "college" => "Hillsdale College Updated"})
# request = request.where('name', 'Bud Acton')
# request.run

# ===== testing delete query =====
# request = MySqliteRequest.new
# request = request.from('nba_player_data_light.csv')
# request = request.delete
# request = request.where('college', 'Hillsdale College Updated')
# request.run
