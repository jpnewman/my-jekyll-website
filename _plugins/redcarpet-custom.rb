# John Paul Newman
# Based On: http://manidesto.github.io/better-code-blocks-in-jekyll

module Jekyll
  module Converters
    class Markdown
      class RedcarpetParser
        module WithPygments
          include CommonMethods
          def block_code(code, lang, code_file_path=nil, title=nil)
            require 'pygments'

            lang = lang && lang.split.first || 'text'
            options = { :encoding => 'utf-8',
                        :lineanchors =>'line' }
            html = add_code_tags(
              Pygments.highlight(code,
                                 :lexer => lang,
                                 :options => options),
              lang
            )

            if lang == 'text'
              output = html
            else
              require 'nokogiri'

              html_doc = Nokogiri::HTML.fragment(html)

              header_div = Nokogiri::XML::Node.new("div", html_doc)
              header_div.content = lang
              header_div.set_attribute('class', 'code-block-header')
              header_div.content = ''

              header_left_div = Nokogiri::XML::Node.new("div", html_doc)
              header_left_div.set_attribute('class', 'code-block-header-left')
              header_left_div.content = ''

              header_div.add_child(header_left_div)

              header_right_div = Nokogiri::XML::Node.new("div", html_doc)
              header_right_div.set_attribute('class', 'code-block-header-right')
              header_right_div.content = '-'

              header_div.add_child(header_right_div)

              title ||= lang
              if code_file_path
                a = Nokogiri::XML::Node.new("a", html_doc)
                a.content = title
                a.set_attribute('href', code_file_path)

                header_left_div.add_child(a)
              end

              html_doc.first_element_child.first_element_child.add_previous_sibling(header_div)
              output = html_doc.to_s
            end
          end
        end
      end
    end
  end
end
