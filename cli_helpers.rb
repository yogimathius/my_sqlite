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

    def parse_select(string)
        delimiters = ['SELECT ', ' FROM ', ' JOIN ', ' ON ', ' WHERE ', ' ORDER BY']

        result = {}
        delimiters.each_with_index do |delimiter, index|
            parts = string.split(delimiter)[1] if string.include?(delimiter)
            if !(string.empty? or parts.nil? or !string.include?(delimiters[index + 1])) && (string and string.include?(delimiters[index + 1]))
              parts = parts.split(delimiters[index + 1])
            end
            parts = parts.first if parts.kind_of?(Array)
            result[delimiter.strip.to_sym] = slice_delims(parts, delimiters)
        end

        result
    end
end