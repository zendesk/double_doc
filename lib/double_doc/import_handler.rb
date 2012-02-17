require 'pathname'
require 'double_doc/doc_extractor'

module DoubleDoc
  class ImportHandler
    def initialize(root)
      @root = Pathname.new(root)
      @docs = {}
    end

    def resolve_imports(source)
      case source
      when String
        resolve_imports_from_lines(source.split("\n"))
      when File
        resolve_imports_from_lines(source.readlines)
      when Array
        resolve_imports_from_lines(source)
      else
        raise "can't extract docs from #{source}"
      end
    end

    protected

    def resolve_imports_from_lines(lines)
      doc = []

      lines.each do |line|
        if match = line.match(/(^|\s+)@import\s+([^\s]+)\s*$/)
          doc << get_doc(match[2])
        else
          doc << line.gsub('@@import', '@import')
        end
      end

      doc.join()
    end

    def get_doc(path)
      return @docs[path] if @docs[path]

      file = File.new(@root + path)

      if path =~ /\.md$/
        @docs[path] = resolve_imports(file)
      else
        @docs[path] = resolve_imports(DocExtractor.extract(file))
      end
    end
  end
end
