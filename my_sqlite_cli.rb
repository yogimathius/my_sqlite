require "readline"
require_relative "my_sqlite_request"
require_relative "cli_helpers"

class MySqliteQueryCli
    def initialize
        @request = MySqliteRequest.new
        @cli_helpers = CliHelpers.new
    end

    def build_where(string)
        where_parts = string.split(" = ")
        where_key = where_parts[0] || nil
        where_value = where_parts[1] || nil
        @request.where(where_key, where_value) unless where_parts.empty?
    end

    def build_join(join_table, join_clause)
        join_id_a, join_id_b = join_clause.split("=").map(&:strip)
        @request.join(join_table, join_id_a, join_id_b)
    end

    def build_order(string)
        column_name, order_type = string.split(" ")
        @request.order(order_type, column_name)
    end

    def build_select(string)
        delimiters = ['SELECT ', ' FROM ', ' JOIN ', ' ON ', ' WHERE ', ' ORDER BY']

        select_object = @cli_helpers.parse_string(string, delimiters)
        
        select_columns = select_object[:SELECT].split(/[,\s]+/)

        build_join(select_object[:JOIN], select_object[:ON]) unless select_object[:JOIN].nil? or select_object[:ON].nil?

        build_where(select_object[:WHERE]) unless select_object[:WHERE].nil?

        build_order(select_object[:ORDER]) unless select_object[:ORDER].nil?

        @request.select(select_columns)
                .from(select_object[:FROM])
    end

    def build_insert(string)
        insert_clause, remaining_clause = string.split(/ VALUES /i)
        insert_into = insert_clause.split(/INTO /i)[1]
        values = remaining_clause.split(",").map(&:strip)
        @request.insert(insert_into)
                .values(values)
    end

    def build_update(string)
        update_clause, remaining_clause = string.split(/ SET /i)
        update_from = update_clause.split(" ")[1]
        set_clause, where_clause = remaining_clause.split(/ WHERE /i)
        set_hash = set_clause.split(",").map do |part|
            key, value = part.split('=').map(&:strip)
            [key, value]
        end.to_h

        build_where(where_clause) unless where_clause.nil?

        @request.update(update_from)
                .set(set_hash)
    end

    def build_delete(string)
        delete_from, where_clause = string.split(/FROM /i)[1].split(/ WHERE /i)
        
        build_where(where_clause) unless where_clause.nil?

        @request.delete
                .from(delete_from)
    end

    def parse(buf)
        if buf.include?(';')

            modified_buf = buf.delete("();'") # remove punctuation
            p modified_buf

            if modified_buf.match?(/SELECT/i)
                result = build_select(modified_buf)
            elsif modified_buf.match?(/INSERT/i)
                result = build_insert(modified_buf)
            elsif modified_buf.match?(/UPDATE/i)
                result = build_update(modified_buf)
            elsif modified_buf.match?(/DELETE/i)
                result = build_delete(modified_buf)
            end
            
            result 
        else
            puts "Invalid syntax: #{buf} does not include closing `;`" unless buf.include?(';')

        end
    end

    def run!
        while buf = Readline.readline("my_sqlite_cli > ", true)
            if buf == 'quit'
                break
            end
            parse(buf)
            @request.run
            @request.reset
        end

    end
end

# to run my_sqlite_cli_test.rb, comment out _main()
# to run in cli, _main() is required
def _main()     
    mysqcli = MySqliteQueryCli.new
    mysqcli.run!
end
    
_main() unless ENV['TEST']
