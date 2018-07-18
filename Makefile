.PHONY: all install build serv clean

all: serv_inc

install:
	sudo gem install bundler
	brew install ruby
	brew install libxml2 libxslt libiconv
	brew install ImageMagick

build:
	bundle exec jekyll build

build_prod: clean
	JEKYLL_ENV=prod bundle exec jekyll build

serv:
	bundle exec jekyll serve


serv_inc:
	bundle exec jekyll serve --incremental

clean:
	bundle exec jekyll clean
