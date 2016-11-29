module DoubleDoc
  class DocExtractor
    TYPES = {
      'rb' => /(^\s*|\s+)##\s?(?<documentation_line>.*?)(?<newline_marker>\\?)$/,
      'js' => %r{(^\s*|\s+)///\s?(?<documentation_line>.*?)(?<newline_marker>\\?)$}
    }.freeze

    def self.extract(source, options = {})
      case source
      when String
        extract_from_lines(source.split("\n"), options)
      when File
        if type = File.extname(source.path)
          type = type[1..-1]
        end
        type ||= 'rb'

        extract_from_lines(source.readlines, options.merge(:type => type))
      when Array
        extract_from_lines(source, options)
      else
        raise "can't extract docs from #{source}"
      end
    end

    def self.extract_from_lines(lines, options)
      doc = []
      extractor = TYPES[options[:type]]

      add_empty_line = false
      append_to_previous = false
      lines.each do |line|
        if match = line.match(extractor)
          if add_empty_line
            doc << ''
            add_empty_line = false
          end
          new_string = match[:documentation_line].rstrip
          if append_to_previous
            doc[-1] << new_string
          else
            doc << new_string
          end
          append_to_previous = !match[:newline_marker].empty?
        else
          add_empty_line = !doc.empty?
        end
      end

      return '' if doc.empty? || doc.all?(&:empty?)

      doc << ''

      return doc.join("\n")
    end
  end
end
