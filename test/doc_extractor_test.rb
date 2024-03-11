require_relative 'test_helper'

describe "the doc extractor" do
  def self.it_acts_like_an_extractor
    it "extracts documentation" do
      _(subject).must_match(/this line should be extracted/)
      _(subject).must_match(/this line should also be extracted/)
      _(subject).must_match(/but this line should/)
    end

    it "doesn't extract regular comments" do
      _(subject).wont_match(/this line should not be extracted/)
    end

    it "doesn't add any extra new-lines" do
      _(subject).must_match(/^this/m)
      _(subject).must_match(/should\n$/m)
    end

    it "adds an empty line between documentation sections" do
      _(subject).must_match(/extracted\n\nthis/m)
    end
  end

  describe "on .rb files" do
    ## this line should be extracted
    # this line should not be extracted
    ## this line should also be extracted
    # puts "Bug##1 this line should not be extracted"
## but this line should

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
        // console.log('/// this line should not be extracted')
/// but this line should
      EOS
      DoubleDoc::DocExtractor.extract(source, :type => 'js')
    end

    it_acts_like_an_extractor
  end
end
