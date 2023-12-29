require "readline"

class MySqliteQueryCli
    def parse(buf)
        p buf
        if buf.include?("SELECT")
            parse_select(buf)
            parse_from(buf)
            parse_where(buf)
        elsif buf.include?("INSERT")
        elsif buf.include?("UPDATE")
        elsif buf.include?("DELETE")
        end

        # parts = buf.split.map(&:upcase)
        # num_tokens = parts.count
    end

    def parse_select(query)

    end


    def run!
        while buf = Readline.readline("> ", true)
            instance_of_request = parse(buf)
            # instance_of_request._run_update
        end
    end
end

mysqcli = MySqliteQueryCli.new
mysqcli.run!

# def _main()
#     loop do
#         mysqcli = MySqliteQueryCli.new
#         break if mysqcli.nil?

#         mysqcli.run!
#     end
# end