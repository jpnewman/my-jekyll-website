# LaTex version of CV

Based On: <https://www.sharelatex.com/templates/cv-or-resume/smart-twenty-seconds-cv>

## TexMaker

- <http://www.xm1math.net/texmaker/>

## Install LaTex Packages (manually)

### Local Package Folder

- <https://www.math.ias.edu/computing/faq/local-latex-style-files>

```bash
mkdir -p ~/texmf/tex/latex
```

### ClearSans

- <https://ctan.org/tex-archive/fonts/clearsans?lang=en>

```bash
wget -P ~/texmf/tex/latex/ http://mirrors.ctan.org/install/fonts/clearsans.tds.zip
```

```bash
unzip ~/texmf/tex/latex/clearsans.tds.zip -d ~/texmf/tex/latex/
```

```bash
texhash
```

## Install LaTex Packages

```bash
sudo tlmgr update --self

sudo tlmgr install fontawesome
sudo tlmgr install clearsans
```

## List System fonts

```bash
fc-list | grep FontAwesome
```

> Results

```bash
/Users/jpnewman/Library/Fonts/fontawesome-regular.ttf: FontAwesome:style=Regular
```

> Font name is ```FontAwesome:style=Regular```

## Generate DevOps.pdf

```bash
/Applications/Inkscape.app/Contents/Resources/bin/inkscape -D -z --file=$(PWD)/../inkscape/DevOps.svg --export-pdf=$(PWD)/DevOps.pdf --export-text-to-path --export-dpi 300
```

## Generate PDF

> Used by WebSite.

```bash
xelatex johnpaul_newman_cv.tex

xelatex -halt-on-error johnpaul_newman_cv.tex
```

```bash
cp johnpaul_newman_cv.pdf ../../johnpaul_newman_cv.pdf
```

## Generate docx

```bash
pandoc -s johnpaul_newman_cv.tex -o johnpaul_newman_cv.docx
```

> Not working well!!!

## Generate HTML

```bash
htxelatex johnpaul_newman_cv.tex
```

> Not working well!!!

## PDF 2 HTML

```bash
pdf2htmlEX johnpaul_newman_cv.pdf
```

## Convert PDF to Grayscale

> ImageMagick

```bash
convert -density 300 -colorspace GRAY johnpaul_newman_cv.pdf johnpaul_newman_cv_bw.pdf
```

## PDFInfo (hypersetup)

```bash
pdfinfo johnpaul_newman_cv.pdf
```

> Results

```bash
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
```

## References

- <https://tug.org/mactex/mactex-download.html>
