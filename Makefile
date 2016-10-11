.PHONY: all install build serv clean

all: serv

install:
	sudo gem install bundler
	brew install ruby
	brew install libxml2 libxslt libiconv
	brew install ImageMagick

build:
	bundle exec jekyll build

serv:
	bundle exec jekyll serve


sev_inc:
	bundle exec jekyll serve --incremental

clean:
	bundle exec jekyll clean
