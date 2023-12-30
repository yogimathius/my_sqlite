require "readline"
require_relative "my_sqlite_request"

class MySqliteQueryCli
    def initialize
        @select_parts = []
        @from_parts = []
        @where_parts = []
        @insert_parts = []
        @insert_values = []
        @update_parts = []
        @set_parts = []
        @delete_parts = []
    end

    def parse_from(index, query)
        where_index = query.index(" WHERE")
        if where_index
            from_length = where_index - index
            from_string = query.slice(index, from_length)
            @from_parts = from_string.split
            parse_where(where_index, query)
        else
            from_string = query.slice(index..)
            @from_parts = from_string.split
        end
    end

    def parse_where(index, query)
        where_string = query.slice(index..)
        @where_parts = where_string.split
    end

    def parse_select(query)
        from_index = query.index(" FROM")
        select_string = query.slice(0, from_index)
        @select_parts = select_string.split
        parse_from(from_index, query)
        # puts "select_parts = #{@select_parts}"
        # puts "from_parts = #{@from_parts}"
        # puts "where_parts = #{@where_parts}"
    end

    def parse(buf)
        p buf
        if buf.include?("SELECT")
            parse_select(buf)
        # elsif buf.include?("INSERT")
        #     parse_insert(buf)
        # elsif buf.include?("UPDATE")
        #     parse_update(buf)
        # elsif buf.include?("DELETE")
        #     parse_delete(buf)
        end
    end

    def run!
        while buf = Readline.readline("my_sqlite_cli > ", true)
            instance_of_request = parse(buf)
            # instance_of_request._run_update
        end

    end
end

def _main()
    mysqcli = MySqliteQueryCli.new
    mysqcli.run!
end
    
_main()
