require "readline"

class MySqliteQueryCli
    def parse(buf)
        p buf
        if select_index = buf.index("SELECT")
        parts = buf.split.map(&:upcase)
        num_tokens = parts.count
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