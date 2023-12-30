require "readline"
require_relative "my_sqlite_request"

class MySqliteQueryCli
    def parse_from(index, string)
        where_index = string.index("WHERE")
        if where_index
            from_length = where_index - index
            from_string = string.slice(index, from_length)
            from_parts = from_string.split
            parse_where(where_index, string)
        else
            from_string = string.slice(index..)
            from_parts = from_string.split
        end
        @request = @request.from(from_parts[1])
    end

    def parse_where(index, string)
        where_string = string.slice(index + 6..)
        where_parts = where_string.split
        @request = @request.where(where_parts[0], where_parts[2])
    end

    def parse_select(string)
        from_index = string.index(" FROM")
        select_string = string.slice(7, from_index - 7)
        select_parts = select_string.split
        @request = @request.select(select_parts)
        parse_from(from_index, string)
    end

    def parse_insert(string)
        values_index = string.index(" VALUES")
        insert_string = string.slice(0, values_index)
        string = string.slice(values_index..)
        value_string = string.delete("(")
        insert_parts = insert_string.split
        value_parts = value_string.split
        puts "insert_parts = #{insert_parts}"
        puts "insert_parts = #{value_parts}"
    end

    def parse(buf)
        @request = MySqliteRequest.new
        p buf
        if buf.include?("SELECT")
            parse_select(buf)
        elsif buf.include?("INSERT")
            parse_insert(buf)
        # elsif buf.include?("UPDATE")
        #     parse_update(buf)
        # elsif buf.include?("DELETE")
        #     parse_delete(buf)
        end

        return @request
    end

    def run!
        while buf = Readline.readline("my_sqlite_cli > ", true)
            instance_of_request = parse(buf)
            instance_of_request.run
            # clear @request ?
        end

    end
end

def _main()
    mysqcli = MySqliteQueryCli.new
    mysqcli.run!
end
    
_main()
