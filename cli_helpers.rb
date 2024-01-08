class CliHelpers
    def slice_delims(parts, delimiters)
        return if parts.nil?
      
        delimiters.each.with_index do |delim| 
            regex = /#{delim}/i
            if parts.match?(regex) 
                parts = parts.split(regex)[0]
          end
        end
      
        parts
    end

    def parse_string(string, delimiters)
        result = {}
        delimiters.each do |delimiter|
            regex = /#{delimiter}/i
            parts = string.split(regex)[1] if string.match?(regex)
            parts = parts.first if parts.kind_of?(Array)
            result[delimiter.strip.to_sym] = slice_delims(parts, delimiters)
        end

        result
    end
end