require 'redcarpet'
require 'pygments'

module DoubleDoc
  class HtmlRenderer

    def self.render(text)
      markdown = Redcarpet::Markdown.new(RedcarpetRenderer, :fenced_code_blocks => true, :no_intra_emphasis => true, :tables => true)
      markdown.render(text)
    end

    def self.generate_id(text)
      text.strip.downcase.gsub(/\s+/, '-')
    end

    class RedcarpetRenderer < Redcarpet::Render::HTML
      def header(text, level)
        "<h#{level} id=\"#{DoubleDoc::HtmlRenderer.generate_id(text)}\">#{text}</h#{level}>"
      end

      def block_code(code, language)
        if language
          Pygments.highlight(code, :lexer => language)
        else
          "<pre>#{code}</pre>"
        end
      end

    end

  end

end
