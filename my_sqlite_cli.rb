require "readline"
require_relative "my_sqlite_request"

class MySqliteQueryCli
    def parse_from(index, string)
        where_index = string.index("WHERE")
        if where_index
            from_length = where_index - index
            from_string = string.slice(index, from_length)
            parse_where(where_index, string)
        else
            from_string = string.slice(index..)
        end
        from_parts = from_string.split
        @request = @request.from(from_parts[1])
    end

    def parse_where(index, string)
        where_string = string.slice(index + 6..)
        where_parts = where_string.split
        range = 2..where_parts.size
        where_value = where_parts[range].join(" ")
        @request = @request.where(where_parts[0], where_value)
    end

    def create_hash(string)
        parts = string.split
        hash = {}
        i = 1

        while i < parts.length - 2
            count = 0
            puts "Line 33, i = #{i}"
            if parts[i + 1] == "="
                j = 3
                while i + j < parts.length && parts[i + j] != ","
                    count += 1
                    j += 1
                end
                range = i + 2..i + 2 + count
                set_value = parts[range].join(" ")
                hash[parts[i]] = set_value
                i += 3
            else
                i += 1
            end
        end

        return hash
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

    def parse_set(index, string)
        where_index = string.index("WHERE")
        if where_index
            set_length = where_index - index
            set_string = string.slice(index, set_length)
            parse_where(where_index, string)
        else
            from_string = string.slice(index..)
        end

        comma_sub = { ',' => ' ,'}
        modified_string = char_replacer(set_string, comma_sub)
        puts "mod string = #{modified_string}"
        set_hash = create_hash(modified_string)
        @request = @request.set(set_hash)
    end

    def parse_select(string)
        from_index = string.index(" FROM")
        select_string = string.slice(7, from_index - 7)
        select_parts = select_string.split(", ")
        @request = @request.select(select_parts)
        parse_from(from_index, string)
    end

    def parse_insert(string)
        values_index = string.index(" VALUES")
        insert_string = string.slice(0, values_index)
        insert_into = insert_string.split
        @request = @request.insert(insert_into[2])
        parse_values(values_index, string)
        # puts "insert_parts = #{insert_parts}"
    end

    def parse_update(string)
        set_index = string.index(" SET")
        update_string = string.slice(0, set_index)
        update_parts = update_string.split
        @request = @request.update(update_parts[1])
        parse_set(set_index, string)
    end

    def parse_delete(string)
        from_index = string.index(" FROM")
        parse_from(from_index, string)
        @request = @request.delete()
    end

    def parse(buf)
        @request = MySqliteRequest.new
        modified_buf = buf.delete("();'") # remove punctuation
        p modified_buf

        if modified_buf.include?("SELECT")
            parse_select(modified_buf)
        # elsif modified_buf.include?("INSERT")
        #     parse_insert(modified_buf)
        elsif modified_buf.include?("UPDATE")
            parse_update(modified_buf)
        elsif modified_buf.include?("DELETE")
            parse_delete(modified_buf)
        end

        return @request
    end

    def run!
        while buf = Readline.readline("my_sqlite_cli > ", true)
            instance_of_request = parse(buf)
            instance_of_request.run
        end

    end
end

def _main()
    mysqcli = MySqliteQueryCli.new
    mysqcli.run!
end
    
_main()
