
convert_app = convert
inkscape_app = /Applications/Inkscape.app/Contents/Resources/bin/inkscape
xelatex_app = xelatex
pdftohtml_app = pdftohtml
clean_cv_html_script = ./_scripts/clean_cv_html/clean_cv_html.py
cv_update_tex_script = ./_scripts/cv_yaml/cv_update_tex.py
cv_update_markdown_script = ./_scripts/cv_yaml/cv_update_markdown.py

.PHONY: all init init_ruby_gems init_docs gen_favicon convert_svg cv_update_tex cv_update_markdown gen_docs gen_html_from_pdf gen_xml_from_pdf build build_debug build_prod prod_upload serv serv_inc clean

all: serv

init:
	brew install ruby || true
	brew install libxml2 libxslt libiconv || true
	brew install ImageMagick || true

init_ruby_gems:
	sudo gem install bundler
	bundle install --path _vendor/bundle

init_docs:
	sudo tlmgr update --self
	sudo tlmgr install fontawesome
	sudo tlmgr install clearsans
	sudo texhash

gen_favicon:
	$(convert_app) -density 384 -background transparent $(PWD)/_docs/favicon/favicon.svg -define icon:auto-resize $(PWD)/favicon.ico

convert_svg:
	# $(inkscape_app) -D -z --file=$(PWD)/_docs/inkscape/DevOps.svg --export-png=$(PWD)/_docs/latex/DevOps.png
	$(inkscape_app) -D -z --file=$(PWD)/_docs/inkscape/DevOps.svg --export-pdf=$(PWD)/_docs/latex/DevOps.pdf --export-text-to-path --export-dpi 300

cv_update_tex:
	$(cv_update_tex_script)

cv_update_markdown:
	$(cv_update_markdown_script)

gen_docs: convert_svg cv_update_tex cv_update_markdown
	cd ./_docs/latex/; \
	$(xelatex_app) johnpaul_newman_cv.tex; \
	cp johnpaul_newman_cv.pdf $(PWD)/johnpaul_newman_cv.pdf

gen_html_from_pdf: gen_docs
	mkdir -p ./_cv; \
	cd ./_cv/; \
	$(pdftohtml_app) -s -i -noframes $(PWD)/johnpaul_newman_cv.pdf
	$(clean_cv_html_script) --file johnpaul_newman_cv.html --outfile cv.html

gen_xml_from_pdf: gen_docs
	$(pdftohtml_app) -s -i -noframes -xml -noroundcoord johnpaul_newman_cv.pdf

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
	bundle exec jekyll clean || true

	rm -f $(PWD)/favicon.ico || true
	rm -f $(PWD)/_docs/latex/DevOps.pdf || true
	rm -f $(PWD)/_docs/latex/johnpaul_newman_cv.pdf || true
	rm -f $(PWD)/johnpaul_newman_cv.pdf || true

	$(PWD)/_docs/latex/latex-clean.sh $(PWD)/_docs/latex/
