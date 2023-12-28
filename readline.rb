require "readline"

class MySqliteQueryCli
    def parse(buf)
        p buf
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