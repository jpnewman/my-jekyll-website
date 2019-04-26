
# LaTex version of CV

Based On: <https://www.sharelatex.com/templates/cv-or-resume/smart-twenty-seconds-cv>

## TexMaker

- <http://www.xm1math.net/texmaker/>

## Install LaTex Packages (manually)

### Local Package Folder

- <https://www.math.ias.edu/computing/faq/local-latex-style-files>

~~~
mkdir -p ~/texmf/tex/latex
~~~

### ClearSans

- <https://ctan.org/tex-archive/fonts/clearsans?lang=en>

~~~
wget -P ~/texmf/tex/latex/ http://mirrors.ctan.org/install/fonts/clearsans.tds.zip
~~~

~~~
unzip ~/texmf/tex/latex/clearsans.tds.zip -d ~/texmf/tex/latex/
~~~

~~~
texhash
~~~


## Install LaTex Packages

~~~
sudo tlmgr update --self

sudo tlmgr install fontawesome
sudo tlmgr install clearsans
~~~

## Generate DevOps.pdf

~~~
/Applications/Inkscape.app/Contents/Resources/bin/inkscape -D -z --file=$(PWD)/../inkscape/DevOps.svg --export-pdf=$(PWD)/DevOps.pdf --export-text-to-path --export-dpi 300
~~~

## Generate PDF

> Used by WebSite.

~~~
xelatex johnpaul_newman_cv.tex

xelatex -halt-on-error johnpaul_newman_cv.tex
~~~

~~~
cp johnpaul_newman_cv.pdf ../../johnpaul_newman_cv.pdf
~~~

## Generate docx

~~~
pandoc -s johnpaul_newman_cv.tex -o johnpaul_newman_cv.docx
~~~

> Not working well!!!

## Generate HTML

~~~
htxelatex johnpaul_newman_cv.tex
~~~

> Not working well!!!

## PDF 2 HTML

~~~
pdf2htmlEX johnpaul_newman_cv.pdf
~~~

## Convert PDF to Grayscale

> ImageMagick

~~~
convert -density 300 -colorspace GRAY johnpaul_newman_cv.pdf johnpaul_newman_cv_bw.pdf
~~~

## PDFInfo (hypersetup)

pdfinfo johnpaul_newman_cv.pdf
~~~

> Results

~~~
Title:          John Paul Newman CV
Subject:        CV
Keywords:       CV
Author:         John Paul Newman
Creator:        LaTeX with hyperref package
Producer:       XeTeX 0.99998
CreationDate:   Mon Oct  1 14:36:26 2018 BST
Tagged:         no
UserProperties: no
Suspects:       no
Form:           none
JavaScript:     no
Pages:          2
Encrypted:      no
Page size:      595.28 x 841.89 pts (A4)
Page rot:       0
File size:      87939 bytes
Optimized:      no
PDF version:    1.5
~~~
