require_relative 'test_helper'

describe "import handler" do
  subject do
    DoubleDoc::Client.new(sources, options)
  end

  describe '#process' do
    let(:destination) { Dir.mktmpdir }
    let(:sources) { [Bundler.root + 'doc/readme.md'] }
    let(:options) { { :md_destination => destination, :roots => [Bundler.root], :quiet => true } }

    before do
      subject.process
    end

    it 'produces output at the md_destination' do
      File.exist?(destination + '/readme.md').must_equal true
    end

    describe 'with a missing directory' do
      let(:destination) { Dir.mktmpdir + '/tmp' }

      it 'creates the directory' do
        File.exist?(destination + '/readme.md').must_equal true
      end
    end

    describe 'with multiple sources' do
      let(:sources) { %w(readme todo).map{|f| Bundler.root + "doc/#{f}.md" } }

      it 'processes all sources' do
        File.exist?(destination + '/readme.md').must_equal true
        File.exist?(destination + '/todo.md').must_equal true
      end
    end

    describe 'producing html' do
      let(:options) { {
        :md_destination => destination,
        :html_destination => destination + '/html',
        :roots => [Bundler.root],
        :quiet => true
      } }

      it 'creates html files' do
        File.exist?(destination + '/html/readme.html').must_equal true
      end
    end
  end
end
