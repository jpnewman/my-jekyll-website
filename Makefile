.PHONY: all install build build_debug build_prod serv serv_inc clean

all: serv_inc

init:
	sudo gem install bundler
	brew install ruby
	brew install libxml2 libxslt libiconv
	brew install ImageMagick

	bundle install --path _vendor/bundle

build:
	bundle exec jekyll build

build_debug: clean
	JEKYLL_LOG_LEVEL=debug bundle exec jekyll build --trace

build_prod: clean
	JEKYLL_ENV=prod bundle exec jekyll build

serv:
	bundle exec jekyll serve


serv_inc:
	bundle exec jekyll serve --incremental

clean:
	bundle exec jekyll clean
