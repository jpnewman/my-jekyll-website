
# pandoc

## Convert

### html

~~~
pandoc -o cv.html -f markdown -t html -c pandoc.css ../../cv.md
~~~

### docx

#### Create style reference doc

~~~
pandoc --print-default-data-file reference.docx > custom-style-reference.docx
~~~

#### Edit style reference doc

~~~
open custom-style-reference.docx
~~~

> Add a space, delete the space and save.

#### Create docx

~~~
pandoc -o cv.docx -f markdown -t docx ../../cv.md
pandoc -o cv.docx -f markdown -t docx+styles --reference-doc custom-style-reference.docx ../../cv.md
~~~
