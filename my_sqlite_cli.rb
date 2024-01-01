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

    def char_replacer(word, subs)
        word.chars.map { |c| subs.key?(c) ? subs[c] : c }.join
    end

    def parse_values(index, string)
        value_string = string.slice(values_index..)
        value_parts = value_string.split
        # TODO: format values
        # @request = @request.values()
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
    
    def parse_insert(string)
        values_index = string.index(" VALUES")
        insert_string = string.slice(0, values_index)
        insert_into = insert_string.split
        @request = @request.insert(insert_into[2])
        parse_values(values_index, string)
        # puts "insert_parts = #{insert_parts}"
    end

    def parse_delete(string)
        from_index = string.index(" FROM")
        parse_from(from_index, string)
        @request = @request.delete()
    end

    def parse(buf)
        modified_buf = buf.delete("();'") # remove punctuation
        p modified_buf

        if modified_buf.include?("SELECT")
            build_select(modified_buf)
        # elsif modified_buf.include?("INSERT")
        #     parse_insert(modified_buf)
        elsif modified_buf.include?("UPDATE")
            build_update(modified_buf)
        elsif modified_buf.include?("DELETE")
            parse_delete(modified_buf)
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