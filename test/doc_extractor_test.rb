require 'test_helper'

describe "the doc extractor" do
  describe "on ruby files" do
    ## this line should be extracted
    # this line should not be extracted
    ## this line should also be extracted

    before do
      @doc = DoubleDoc::DocExtractor.extract(File.new(__FILE__))
    end

    it "should extract documentation from ruby files" do
      @doc.must_match(/this line should be extracted/)
      @doc.must_match(/this line should also be extracted/)
    end

    it "should not extract regular comments" do
      @doc.wont_match(/this line should not be extracted/)
    end

    it "should not add any extra new-lines" do
      @doc.must_match(/^this/m)
      @doc.must_match(/extracted\n$/m)
    end

    it "add an empty line between documentation sections" do
      @doc.must_match(/extracted\n\nthis/m)
    end
  end
end
