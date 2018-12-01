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

      page_path = context.registers[:page]['path']
      page_path = page_path[0..-9] if page_path =~ %r{\/#excerpt$}
      post_path = File.dirname(page_path)

      sc = context.registers[:page]['source_codes'].find {|e| e['file'] == @source_codes_file_filter}
      if sc.nil?
        raise "Please include '#{@source_codes_file_filter}' file in source_codes within the front matter"
      end

      file_path = File.join(post_path, @source_codes_file_filter)
      text = File.open(file_path).read

      block_code(text, sc['language'], sc['file'], sc['title'])
    end
  end
end

Liquid::Template.register_tag('source_code', Jekyll::SourceCode)
