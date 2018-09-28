
# DevOps graphic for CV.

Based On: <https://logosbynick.com/inkscape-infographic-template/>

## Convert to SVG

<https://tex.stackexchange.com/questions/2099/how-to-include-svg-diagrams-in-latex>

## Convert to PDF

~~~
/Applications/Inkscape.app/Contents/Resources/bin/inkscape -D -z --file=$(PWD)/DevOps.svg --export-pdf=$(PWD)/DevOps.pdf --export-latex
~~~

## Convert to PNG

> Used for LaTex version of CV.

~~~
/Applications/Inkscape.app/Contents/Resources/bin/inkscape -D -z --file=$(PWD)/DevOps.svg --export-png=$(PWD)/../latex/DevOps.png
~~~
