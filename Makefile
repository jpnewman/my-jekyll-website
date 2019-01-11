
convert_app = convert
inkscape_app = /Applications/Inkscape.app/Contents/Resources/bin/inkscape
xelatex_app = xelatex

.PHONY: all init gen_favicon gen_svg gen_docs build build_debug build_prod prod_upload serv serv_inc clean

all: serv

init:
	sudo gem install bundler
	brew install ruby
	brew install libxml2 libxslt libiconv
	brew install ImageMagick

	bundle install --path _vendor/bundle

gen_favicon:
	$(convert_app) -density 384 -background transparent $(PWD)/_docs/favicon/favicon.svg -define icon:auto-resize $(PWD)/favicon.ico

gen_svg:
	$(inkscape_app) -D -z --file=$(PWD)/_docs/inkscape/DevOps.svg --export-png=$(PWD)/_docs/latex/DevOps.png

gen_docs: gen_svg
	cd ./_docs/latex/; \
	$(xelatex_app) johnpaul_newman_cv.tex; \
	cp johnpaul_newman_cv.pdf $(PWD)/johnpaul_newman_cv.pdf

build: gen_favicon gen_docs
	bundle exec jekyll build

build_debug: clean gen_favicon gen_docs
	JEKYLL_LOG_LEVEL=debug bundle exec jekyll build --trace

build_prod: clean gen_favicon gen_docs
	JEKYLL_ENV=prod bundle exec jekyll build

prod_upload: build_prod
	aws s3 sync --delete ./_site s3://johnpaulnewman.com --acl public-read --profile mysite

serv: clean build
	bundle exec jekyll serve

serv_inc:
	bundle exec jekyll serve --incremental

clean:
	bundle exec jekyll clean

	rm -f $(PWD)/favicon.ico || true
	rm -f $(PWD)/johnpaul_newman_cv.pdf || true
