module Jekyll
  module Converters
    class Markdown
      class RedcarpetParser
        module WithPygments
          include CommonMethods
          def block_code(code, lang, code_file_path=nil)
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

              div = Nokogiri::XML::Node.new("div", html_doc)
              div.content = lang
              div.set_attribute('class', 'code-block-header')

              if code_file_path
                a = Nokogiri::XML::Node.new("a", html_doc)
                a.content = lang
                a.set_attribute('href', code_file_path)

                div.content = ''
                div.add_child(a)
              end

              html_doc.first_element_child.first_element_child.add_previous_sibling(div)
              output = html_doc.to_s
            end
          end
        end
      end
    end
  end
end
