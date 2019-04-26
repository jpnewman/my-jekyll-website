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

bundle install --path _vendor/bundle
~~~

## Set RVM

- <https://usabilityetc.com/articles/ruby-on-mac-os-x-with-rvm/>
- <https://rvm.io/rvm/install>

~~~
brew install gnupg
~~~

~~~
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
~~~

~~~
curl -sSL https://get.rvm.io | bash -s stable --ruby
~~~

~~~
rvm install 2.5.1
~~~

> Restart the shell.

## Set Environment

~~~
rvm use ruby-2.5.1
~~~

## Generate CV PDF

- [InkScape](_docs/inkscape)
- [LaTex](_docs/latex)

~~~
make gen_docs
~~~

## Serve Blog, generate pages

~~~
bundle exec jekyll serve
~~~

# Serve Blog, watch

~~~
bundle exec jekyll serve --watch
~~~

## Run without generating

~~~
cd _site
ruby -run -e httpd . -p 4000

python -m SimpleHTTPServer 4000
~~~

# Build, without serving

~~~
make build
~~~

# Build, debug logging

~~~
make build_debug
~~~

# Build, debug and trace

~~~
make build_debug
~~~

# Build, PROD

~~~
make build_prod
~~~

# Clean

~~~
make clean
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
