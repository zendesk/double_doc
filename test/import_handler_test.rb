require 'test_helper'

describe "import handler" do
  subject do
    DoubleDoc::ImportHandler.new(root, options)
  end

  before do
    ENV["BUNDLE_GEMFILE"] = File.join(File.expand_path(File.dirname(__FILE__)), "..", "Gemfile")
  end

  describe "with gemfile" do
    let(:root) { Bundler.root }
    let(:options) {{ :gemfile => true }}

    describe "rubygems" do
      let(:root) { Bundler.root }

      describe "load_paths" do
        it "should add Gemfile load paths" do
          subject.load_paths.wont_equal [subject.root]
        end
      end

      describe "find_file" do
        it "should resolve files" do
          subject.send(:find_file, "bundler.rb").must_be_instance_of File
        end

        it "should raise if unable to find file" do
          lambda do
            subject.send(:find_file, "nope.rb")
          end.must_raise LoadError
        end
      end
    end

    describe "path, git" do
      let(:root) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures") }

      describe "find_file" do
        it "should resolve files from path" do
          subject.send(:find_file, "double_doc.rb").must_be_instance_of File
        end

        it "should resolve file from git" do
          subject.send(:find_file, "zendesk_api.rb").must_be_instance_of File
        end
      end
    end
  end
end
