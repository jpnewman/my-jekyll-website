# John Paul Newman

require 'fileutils'

module Jekyll

  # Monkey-patch an accessor for a page's containing folder, since
  # we need it to generate the source coce.
  class Page
    def subfolder
      @dir
    end
  end


  # Sub-class Jekyll::StaticFile to allow recovery from unimportant exception
  # when writing the source code file.
  class StaticSourceCodeFile < StaticFile
    def initialize(site, base, dir, name, collection = nil, sub_path = '_code')
      super(site, base, dir, name, collection)
      @sub_path = sub_path
    end

    def write(dest)
      super(dest) rescue ArgumentError
      true
    end

    def destination(dest)
        File.join(dest, @sub_path, @name)
    end
  end

  class SourceCodeGenerator < Generator
    safe true
    priority :low

    def generate(site)
      posts = site.site_payload['site']['posts']
      for post in posts do
        url     = post.url
        url     = '/' + url unless url =~ /^\//
        url     = url[0..-11] if url=~/\/index.html$/

        next unless post.populate_tags.has_key?('source_code')

        post.populate_tags['source_code'].each do |sc|
          file_name = File.basename(sc['file'])
          file_subfolder = File.dirname(sc['file'])

          target_subpath = File.join(File.dirname(url), file_subfolder)
          target_path = File.join(site.config['destination'], target_subpath)

          unless File.directory?(target_path)
            FileUtils::mkdir_p target_path
          end

          source_file = File.join(File.dirname(post.path), sc['file'])
          site.static_files << Jekyll::StaticSourceCodeFile.new(site, File.join(site.source, '_posts'), file_subfolder, file_name, nil, target_subpath)
        end
      end

    end
  end

end
