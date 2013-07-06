require 'pathname'
require 'double_doc/doc_extractor'
require 'bundler'

module DoubleDoc
  class ImportHandler
    attr_reader :root, :load_paths

    def initialize(root, options = {})
      @root = Pathname.new(root)
      @load_paths = [@root]

      begin
        @load_paths.concat(load_paths_from_gemfile(@root))
      rescue => e
        puts "Could not load paths from Gemfile; please make sure you've run bundle install with the correct gemset."
        raise e
      end

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

    def load_paths_from_gemfile(root)
      gemfile = root + "Gemfile"

      unless gemfile.exist?
        raise LoadError, "missing Gemfile inside #{root}"
      end

      with_gemfile(gemfile) do
        puts "Loading paths from #{gemfile}"

        defn = Bundler::Definition.build(gemfile, root + "Gemfile.lock", nil)
        defn.validate_ruby!
        defn.resolve_with_cache!

        defn.specs.inject([]) do |paths, spec|
          paths.concat(spec.load_paths.map {|p| Pathname.new(p)})
        end
      end
    end

    def resolve_imports_from_lines(lines)
      doc = []

      lines.each do |line|
        if match = line.match(/(^|\s+)@import\s+([^\s]+)\s*$/)
          doc << get_doc(match[2])
        else
          doc << line.gsub('@@import', '@import').rstrip
        end
      end

      doc.join("\n")
    end

    def get_doc(path)
      return @docs[path] if @docs[path]

      file = find_file(path)

      if path =~ /\.md$/
        @docs[path] = resolve_imports(file)
      else
        @docs[path] = resolve_imports(DocExtractor.extract(file))
      end
    end

    def find_file(path)
      load_path = @load_paths.detect do |load_path|
        (load_path + path).exist?
      end

      unless load_path
        raise LoadError, "No such file or directory: #{path}"
      end

      File.new(load_path + path)
    end

    def with_gemfile(gemfile)
      ENV["BUNDLE_GEMFILE"], orig_gemfile = gemfile.to_s, ENV["BUNDLE_GEMFILE"]
      yield
    ensure
      ENV["BUNDLE_GEMFILE"] = orig_gemfile
    end
  end
end
