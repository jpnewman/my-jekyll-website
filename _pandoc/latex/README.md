
# LaTex version of CV

Based On: <https://www.sharelatex.com/templates/cv-or-resume/smart-twenty-seconds-cv>

## Generate PDF

> Used by WebSite.

~~~
xelatex johnpaul_newman_cv.tex

xelatex -halt-on-error johnpaul_newman_cv.tex
~~~

~~~
cp johnpaul_newman_cv.pdf ../../johnpaul_newman_cv.pdf
~~~

## Generate HTML

~~~
htxelatex johnpaul_newman_cv.tex
~~~

> Not working well!

## PDF 2 HTML

~~~
pdf2htmlEX johnpaul_newman_cv.pdf
~~~

## Convert PDF to Grayscale

> ImageMagick

~~~
convert -density 300 -colorspace GRAY johnpaul_newman_cv.pdf johnpaul_newman_cv_bw.pdf
~~~
