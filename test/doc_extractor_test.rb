require 'test_helper'

describe "the doc extractor" do

  def self.it_acts_like_an_extractor
    it "extracts documentation" do
      subject.must_match(/this line should be extracted/)
      subject.must_match(/this line should also be extracted/)
    end

    it "doesn't extract regular comments" do
      subject.wont_match(/this line should not be extracted/)
    end

    it "doesn't add any extra new-lines" do
      subject.must_match(/^this/m)
      subject.must_match(/extracted\n$/m)
    end

    it "adds an empty line between documentation sections" do
      subject.must_match(/extracted\n\nthis/m)
    end
  end

  describe "on .rb files" do
    ## this line should be extracted
    # this line should not be extracted
    ## this line should also be extracted

    subject do
      DoubleDoc::DocExtractor.extract(File.new(__FILE__))
    end

    it_acts_like_an_extractor
  end

  describe 'on .js files' do
    subject do
      source = <<-EOS
        /// this line should be extracted
        // this line should not be extracted
        /// this line should also be extracted
      EOS
      DoubleDoc::DocExtractor.extract(source, :type => 'js')
    end

    it_acts_like_an_extractor
  end
end
