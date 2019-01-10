
inkscape_app = /Applications/Inkscape.app/Contents/Resources/bin/inkscape
xelatex_app = xelatex

.PHONY: all init gen_docs build build_debug build_prod prod_upload serv serv_inc clean

all: serv

init:
	sudo gem install bundler
	brew install ruby
	brew install libxml2 libxslt libiconv
	brew install ImageMagick

	bundle install --path _vendor/bundle

gen_docs:
	$(inkscape_app) -D -z --file=$(PWD)/_docs/inkscape/DevOps.svg --export-png=$(PWD)/_docs/latex/DevOps.png

	cd ./_docs/latex/; \
	$(xelatex_app) johnpaul_newman_cv.tex; \
	cp johnpaul_newman_cv.pdf ../../johnpaul_newman_cv.pdf

build: gen_docs
	bundle exec jekyll build

build_debug: clean gen_docs
	JEKYLL_LOG_LEVEL=debug bundle exec jekyll build --trace

build_prod: clean gen_docs
	JEKYLL_ENV=prod bundle exec jekyll build

prod_upload: build_prod
	aws s3 sync --delete ./_site s3://johnpaulnewman.com --acl public-read --profile mysite

serv: build
	bundle exec jekyll serve

serv_inc:
	bundle exec jekyll serve --incremental

clean:
	bundle exec jekyll clean
