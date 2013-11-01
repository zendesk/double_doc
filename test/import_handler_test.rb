require 'test_helper'

describe "import handler" do
  subject do
    DoubleDoc::ImportHandler.new(root, options)
  end

  after do
    ENV["BUNDLE_GEMFILE"] = Bundler.root.join("Gemfile").to_s
  end

  describe "with gemfile" do
    let(:root) { Bundler.root }
    let(:options) {{ :gemfile => true }}

    describe "rubygems" do
      describe "load_paths" do
        it "should add Gemfile load paths" do
          subject.load_paths.must_include root
          subject.load_paths.size.must_be :>, 1
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

    describe "find_file" do
      it "should resolve files from path" do
        subject.send(:find_file, "double_doc.rb").must_be_instance_of File
      end

      it "should resolve file from git" do
        subject.send(:find_file, "mime-types.rb").must_be_instance_of File
      end
    end
  end
end
