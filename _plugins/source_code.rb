# John Paul Newman
# TODO: Implement

module Jekyll
  class SourceCode < Liquid::Tag
    include Jekyll::Converters::Markdown::RedcarpetParser::WithPygments
    safe = true

    def initialize(name, file_filter=nil, tokens=nil)
      super
      @file_filter = file_filter.strip
    end

    def render(context)
        unless context.registers[:page].has_key?('source_code')
          #raise 'Please include source_code in frontmatter'
          return
        end

        post_path = File.dirname(context.registers[:page].path)

        html = ''

        context.registers[:page]['source_code'].each do |sc|
          unless @file_filter.nil? || @file_filter.empty?
            next unless @file_filter.downcase == sc['file'].downcase
          end

          file_path = File.join(post_path, sc['file'])
          text = File.open(file_path).read
          html << block_code(text, sc['language'], sc['file'])
        end

        html
    end
  end

end

Liquid::Template.register_tag('source_code', Jekyll::SourceCode)
