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
    reset
  end

  def reset 
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
    count = 0

    data = @join_attributes.empty? ? CSV.parse(File.read(@table_name), headers: true) : _run_join_select
    
    data.each_with_index do |row, index|
        next if index == 0 && @join_attributes.any?
        row = row.to_hash unless row.class == Hash

        selected_columns = if @select_columns[0] != "*"
            row.slice(*@select_columns).values.join("|")
        else
            row.values.join("|")
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

    puts result.empty? ? "No results found." : result.join("\n")
    rescue => error
        puts "error selecting from table: '#{@table_name}': #{error}"
  end

  # Borrowed from https://stackoverflow.com/questions/58304715/merge-csv-files-same-unique-id-with-ruby
  def _run_join_select
    dict = Hash.new

    csv_one = CSV.read(@table_name, headers: true)
    csv_two = CSV.read(@join_attributes[:filename_db_b], headers: true)

    rows = [[csv_one.headers, csv_two.headers].flatten]

    # read file1
    csv_one.each do |row|
        row = row.to_h
        user = "#{row[@join_attributes[:column_on_db_a]]}"
        dict[user] = row
    end

    # read file2
    csv_two.each do |row|
        row = row.to_h
        user = "#{row[@join_attributes[:column_on_db_b]]}"
        row.delete(@join_attributes[:column_on_db_b])
        dict[user] = row.merge(dict[user]) if dict[user]
    end

    # # turn hash into rows
    dict.each do |key, value|
        rows.push(value)
    end
    rows
    rescue => error
        puts "error joining table: '#{@join_attributes[:filename_db_b]}': #{error}"
  end
  
  def _run_insert
    File.open(@table_name, 'a') do |f|
        f.puts @insert_attributes.join(',')
    end
    rescue => error
        puts "error inserting into table: '#{@table_name}': #{error}"
  end

  def _run_delete
    csv = CSV.read(@table_name, headers: true)
    
    csv.delete_if do |row|
        @where_params.any? ? @where_params.any? { |where_attribute| row[where_attribute[0]] == where_attribute[1] } : true
    end
    File.open(@table_name, 'w') { |f| f.puts(csv) }
    rescue => error
        puts "error deleting from table: '#{@table_name}': #{error}"
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
    rescue => error
        puts "error updating table: '#{@table_name}': #{error}"
  end

  def _setTypeOfRequest(new_type)
    if (@type_of_request == :none or @type_of_request == new_type)
        @type_of_request = new_type
    else
        raise "Invalid: type of request already set to #{@type_of_request} (new_type => #{@new_type})"
    end
  end
end

