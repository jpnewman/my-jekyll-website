
# pandoc

## Convert Markdown

### To HTML

~~~
pandoc -o cv.html -f markdown -t html -c pandoc.css ../../cv.md
~~~

### To DOCX

1. Create style reference doc

    ~~~
    pandoc --print-default-data-file reference.docx > custom-style-reference.docx
    ~~~

2. Edit style reference doc

    ~~~
    open custom-style-reference.docx
    ~~~

    > Add a space, delete the space and save.

3. Create docx

    ~~~
    pandoc -o cv.docx -f markdown -t docx ../../cv.md
    pandoc -o cv.docx -f markdown -t docx+styles --reference-doc custom-style-reference.docx ../../cv.md
    ~~~
