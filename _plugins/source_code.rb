# John Paul Newman

module Jekyll
  class SourceCode < Liquid::Tag
    include Jekyll::Converters::Markdown::RedcarpetParser::WithPygments
    safe = true

    def initialize(tag_name, source_codes_file_filter, tokens = nil)
      super
      @source_codes_file_filter = source_codes_file_filter.strip
    end

    def render(context)
      unless context.registers[:page].key?('source_codes')
        raise 'Please include source_codes in front matter'
      end

      page_path = context.registers[:page].path
      page_path = page_path[0..-9] if page_path =~ %r{\/#excerpt$}
      post_path = File.dirname(page_path)

      html = ''

      context.registers[:page]['source_codes'].each do |sc|
        next unless @source_codes_file_filter.casecmp?(sc['file'])
        file_path = File.join(post_path, sc['file'])

        Jekyll.logger.debug 'SourceCode: path', context.registers[:page].path
        Jekyll.logger.debug 'SourceCode: post_path', post_path
        Jekyll.logger.debug 'SourceCode: file_path', file_path

        text = File.open(file_path).read
        html = block_code(text, sc['language'], sc['file'], sc['title'])
      end

      html
    end
  end
end

Liquid::Template.register_tag('source_code', Jekyll::SourceCode)
