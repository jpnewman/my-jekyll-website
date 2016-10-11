# My DevOps CMDs

## Setup

~~~
sudo gem install bundler

# bundle config build.nokogiri --use-system-libraries

brew install ruby
brew install libxml2 libxslt libiconv

bundle config build.nokogiri \
  --use-system-libraries \
  --with-xml2-include=/usr/local/Cellar/libxml2/2.9.3/include/libxml2 \
  --with-xml2-lib=/usr/local/Cellar/libxml2/2.9.3/lib  \
  --with-xslt-dir=/usr/local/Cellar/libxslt/1.1.28_1/  \
  --with-iconv-include=/usr/local/Cellar/libiconv/1.14/include  \
  --with-iconv-lib=/usr/local/Cellar/libiconv/1.14/lib \
  --ruby=/usr/local/Cellar/ruby/2.3.0/bin/ruby


brew install ImageMagick

bundle install --path vendor/bundle
~~~

## Serve Blog, generate pages

~~~
bundle exec jekyll serve
~~~

## Run without generating

~~~
cd _site
ruby -run -e httpd . -p 4000

python -m SimpleHTTPServer 4000
~~~

# Build, without serving

~~~
bundle exec jekyll build
~~~

# Clean

~~~
bundle exec jekyll clean
~~~

## Open site

~~~
open http://127.0.0.1:4000
~~~

[http://127.0.0.1:4000/]()

## Plugins

### New Post

[https://github.com/jekyll/jekyll-compose]()

~~~
bundle exec jekyll post "XSLT functions with Javascript"
~~~

# Convert TXT files to Jekyll Markdown files

~~~
ruby _scripts/convert_files.rb
~~~
