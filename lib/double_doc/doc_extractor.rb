module DoubleDoc
  class DocExtractor
    def self.extract(source)
      case source
      when String
        extract_from_lines(source.split("\n"))
      when File
        extract_from_lines(source.readlines)
      when Array
        extract_from_lines(source)
      else
        raise "can't extract docs from #{source}"
      end
    end

    def self.extract_from_lines(lines)
      doc = []
      add_empty_line = false
      lines.each do |line|
        if match = line.match(/\s*##\s?(.*)$/)
          if add_empty_line
            doc << ''
            add_empty_line = false
          end
          doc << match[1].rstrip
        else
          add_empty_line = true
        end
      end

      return '' if doc.empty? || doc.all?(&:empty?)

      return doc.join("\n")
    end
  end
end
