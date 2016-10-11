module Jekyll
  class PopularTags < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
    end

    def render(context)
      tags = context.registers[:site].tags

      html = "<ul>"
      sorted = tags.sort_by { |t,posts| posts.count }.reverse
      sorted.each do |t, posts|
        html << "<li><a href='/tag/#{t}'>#{t} (#{posts.count})</a></li>"
      end
      html << "</ul>"

      html
    end
  end
end

Liquid::Template.register_tag('popular_tags', Jekyll::PopularTags)
