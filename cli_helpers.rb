class CliHelpers
    def slice_delims(parts, delimiters)
        return if parts.nil?
      
        delimiters.each.with_index do |delim| 
          if parts.include?(delim) 
            parts = parts.split(delim)[0]
          end
        end
      
        parts
    end

    def parse_string(string, delimiters)
        result = {}
        delimiters.each do |delimiter|
            parts = string.split(delimiter)[1] if string.include?(delimiter)
            parts = parts.first if parts.kind_of?(Array)
            result[delimiter.strip.to_sym] = slice_delims(parts, delimiters)
        end

        result
    end
end