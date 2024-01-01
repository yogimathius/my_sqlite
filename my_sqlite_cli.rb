require "readline"
require_relative "my_sqlite_request"

class MySqliteQueryCli
    def initialize
        @request = MySqliteRequest.new
    end

    def build_select(string)
        remaining_clause, where_clause = string.split("SELECT ")[1].split(" WHERE ")

        select_clause, from_table = remaining_clause.split("FROM ")
        p from_table
        select_columns = select_clause.split(/[,\s]+/)
        p select_columns
        where_parts = where_clause.split(" = ")

        where_key = where_parts[0] || nil
        where_value = where_parts[1] || nil
        
        @request.select(select_columns)
                .from(from_table)
                .where(where_key, where_value) unless where_parts.empty?
    end

    def build_insert(string)
        insert_clause, remaining_clause = string.split(" VALUES ")
        insert_into = insert_clause.split("INTO ")[1]
        values = remaining_clause.split(",")
        # set_hash = set_clause.split(",").map do |part|
        #     part = part.split(' = ')
        #     [part[0].strip, part[1].gsub("'", '').strip] 
        end.to_h

        @request.insert(insert_into)
                .values()
    end

    def build_update(string)
        update_clause, remaining_clause = string.split(" SET ")
        update_from = update_clause.split(" ")[1]
        set_clause, where_clause = remaining_clause.split(" WHERE ")
        set_hash = set_clause.split(",").map do |part|
            part = part.split(' = ')
            [part[0].strip, part[1].gsub("'", '').strip] 
        end.to_h

        where_parts = where_clause.split(" = ")

        @request.update(update_from)
                .set(set_hash)
                .where(where_parts[0], where_parts[1])
    end

    def build_delete(string)
        delete_from, where_clause = string.split("FROM ")[1].split(" WHERE ")
        where_parts = where_clause.split(" = ")

        where_key = where_parts[0] || nil
        where_value = where_parts[1] || nil

        @request.delete()
                .from()
                .where(where_key, where_value) unless where_parts.empty?
    end

    def parse(buf)
        modified_buf = buf.delete("();'") # remove punctuation
        p modified_buf

        if modified_buf.include?("SELECT")
            build_select(modified_buf)
        elsif modified_buf.include?("INSERT")
            build_insert(modified_buf)
        elsif modified_buf.include?("UPDATE")
            build_update(modified_buf)
        elsif modified_buf.include?("DELETE")
            build_delete(modified_buf)
        end

    end

    def run!
        while buf = Readline.readline("my_sqlite_cli > ", true)
            parse(buf)
            @request.run
        end

    end
end

# def _main()
#     mysqcli = MySqliteQueryCli.new
#     mysqcli.run!
# end
    
# _main()


# UPDATE nba_player_data_light.csv SET name = 'Bud Acton' WHERE name = 'Bud Updated';