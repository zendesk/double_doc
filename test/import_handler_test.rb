require_relative 'test_helper'

describe "import handler" do
  subject do
    roots = Array(root).push(options.merge( :quiet => true ))
    DoubleDoc::ImportHandler.new(*roots)
  end

  after do
    ENV["BUNDLE_GEMFILE"] = Bundler.root.join("Gemfile").to_s
  end

  describe "multiple roots" do
    let(:root) { [Bundler.root + 'lib', Bundler.root + 'doc'] }
    let(:options) {{}}

    it "finds files from either root" do
      _(subject.find_file("double_doc.rb")).must_be_instance_of File
      _(subject.find_file("readme.md")).must_be_instance_of File
    end
  end

  describe "with gemfile" do
    let(:root) { Bundler.root }
    let(:options) {{ :gemfile => true }}

    describe "rubygems" do
      describe "load_paths" do
        it "should add Gemfile load paths" do
          _(subject.load_paths).must_include root
          _(subject.load_paths.size).must_be :>, 1
        end
      end

      describe "find_file" do
        it "should resolve files" do
          _(subject.find_file("redcarpet.rb")).must_be_instance_of File
        end

        it "should raise if unable to find file" do
          _{ subject.find_file("nope.rb") }.must_raise LoadError
        end
      end
    end

    describe "find_file" do
      it "should resolve files from path" do
        _(subject.find_file("double_doc.rb")).must_be_instance_of File
      end

      it "should resolve file from git" do
        _(subject.find_file("mime-types.rb")).must_be_instance_of File
      end
    end
  end
end
