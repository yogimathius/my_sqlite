require "readline"
require_relative 'my_sqlite_request'

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

    def parse_select(query)
        from_index = query.index(" FROM")
        where_index = query.index(" WHERE")

        select_string = query.slice(0, from_index)
        @select_parts = select_string.split
        puts "Select Parts #{@select_parts}"
        if where_index
            from_length = where_index - from_index
            from_string = query.slice(from_index, from_length)
            @from_parts = from_string.split
            puts "From Parts #{@from_parts}"
        end
    end

    # def parse_insert(query)

    # end

    def parse(buf)
        p buf
        if buf.include?("SELECT")
            parse_select(buf)
            # parse_from(buf)
            # parse_where(buf)
        # elsif buf.include?("INSERT")
        #     parse_insert(buf)
        #     parse_i_values(buf)
        # elsif buf.include?("UPDATE")
        #     parse_update(buf)
        #     parse_set(buf)
        #     parse_where(buf)
        # elsif buf.include?("DELETE")
        #     parse_delete(buf)
        #     parse_where(buf)
        end
    end

    def run!
        while buf = Readline.readline("> ", true)
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
