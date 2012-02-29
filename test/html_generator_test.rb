require 'test_helper'
require 'pathname'
require 'tmpdir'

describe "the html generator" do
  before do
    @root = Pathname.new(Dir.mktmpdir)
    @input_file_name  = @root + 'source/input.md'
    @destination      = @root + 'destination'
    @output_file_name = @destination + 'input.html'
    Dir.mkdir(@root + 'source')
    Dir.mkdir(@destination)
    @generator = DoubleDoc::HtmlGenerator.new([@input_file_name], { :html_destination => @destination })
  end

  after do
    FileUtils.rm_rf(@root)
  end

  describe "#generate" do
    before do
      File.open(@input_file_name, 'w') do |f|
        f.puts "## Hello"
        f.puts "and some text and a link to [the other file](other.md)"
        f.puts "and a link with params [params](params.md?foo=bar)"
        f.puts "and a link with a fragment [params](params.md#foo-bar)"
      end

      File.open(@destination + 'some_trash.html', 'w') do |f|
        f.puts 'what ever'
      end

      @generator.generate
    end

    it "should put an html document in the destination directory" do
      assert File.exist?(@output_file_name), 'did not create the html file'
    end

    it "should convert .md links to .html links" do
      output = File.read(@output_file_name)
      output.must_match(/<a href="other.html">the other file<\/a>/)
      output.must_match(/<a href="params.html\?foo=bar">params<\/a>/)
      output.must_match(/<a href="params.html#foo-bar">params<\/a>/)
    end

    it "should clean the destination for other files" do
      assert !File.exist?(@destination + 'some_trash.html'), 'did not clean the destination directory'
    end
  end
end
