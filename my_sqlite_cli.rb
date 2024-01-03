require "readline"
require_relative "my_sqlite_request"

class MySqliteQueryCli
    def initialize
        @request = MySqliteRequest.new
    end

    def build_where(string)
        where_parts = string.split(" = ")
        where_key = where_parts[0] || nil
        where_value = where_parts[1] || nil
        @request.where(where_key, where_value) unless where_parts.empty?
    end

    def build_join(string)
        join_table, join_clause = string.split(" ON ")
        join_id_a, join_id_b = join_clause.split("=").map(&:strip)
        puts "join_table = #{join_table}\njoin_ids = #{join_id_a}, #{join_id_b}"
        @request.join(join_table, join_id_a, join_id_b)
    end

    def build_select(string)
        remaining_clause, where_clause = string.split("SELECT ")[1].split(" WHERE ")

        select_clause, from_clause = remaining_clause.split("FROM ")
        from_table, join_clause = from_clause.split(" JOIN ")
        select_columns = select_clause.split(/[,\s]+/)

        build_join(join_clause) unless join_clause.nil?

        build_where(where_clause) unless where_clause.nil?

        @request.select(select_columns)
                .from(from_table)
    end

    def build_insert(string)
        insert_clause, remaining_clause = string.split(" VALUES ")
        insert_into = insert_clause.split("INTO ")[1]
        values = remaining_clause.split(",").map(&:strip)
        @request.insert(insert_into)
                .values(values)
    end

    def build_update(string)
        update_clause, remaining_clause = string.split(" SET ")
        update_from = update_clause.split(" ")[1]
        set_clause, where_clause = remaining_clause.split(" WHERE ")
        set_hash = set_clause.split(",").map do |part|
            key, value = part.split('=').map(&:strip)
            [key, value]
        end.to_h

        build_where(where_clause) unless where_clause.nil?

        @request.update(update_from)
                .set(set_hash)
    end

    def build_delete(string)
        delete_from, where_clause = string.split("FROM ")[1].split(" WHERE ")
        
        build_where(where_clause) unless where_clause.nil?

        @request.delete()
                .from(delete_from)
    end

    def parse(buf)
        modified_buf = buf.delete("();'") # remove punctuation
        p modified_buf

        if modified_buf.include?("SELECT")
            result = build_select(modified_buf)
        elsif modified_buf.include?("INSERT")
            result = build_insert(modified_buf)
        elsif modified_buf.include?("UPDATE")
            result = build_update(modified_buf)
        elsif modified_buf.include?("DELETE")
            result = build_delete(modified_buf)
        end
        
        result 
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
