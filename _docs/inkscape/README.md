# DevOps graphic for CV

Based On: <https://logosbynick.com/inkscape-infographic-template/>

## Convert to SVG

<https://tex.stackexchange.com/questions/2099/how-to-include-svg-diagrams-in-latex>

## Convert to PDF

```bash
/Applications/Inkscape.app/Contents/MacOS/inkscape $(PWD)/DevOps.svg --export-filename=$(PWD)/DevOps.pdf --export-type="pdf" --export-dpi 300 --export-latex
```

> Used for LaTex version of CV

```bash
./convert-svg-to-pdf.sh
```

-- or --

```bash
/Applications/Inkscape.app/Contents/MacOS/inkscape $(PWD)/DevOps.svg --export-filename=$(PWD)/../latex/DevOps.pdf --export-type="pdf" --export-text-to-path --export-dpi 300

/Applications/Inkscape.app/Contents/MacOS/inkscape $(PWD)/WorkExperience_RateSetter.svg --export-filename=$(PWD)/../latex/WorkExperience_RateSetter.pdf --export-type="pdf" --export-text-to-path --export-dpi 300

/Applications/Inkscape.app/Contents/MacOS/inkscape $(PWD)/WorkExperience_Wonga.svg --export-filename=$(PWD)/../latex/WorkExperience_Wonga.pdf --export-type="pdf" --export-text-to-path --export-dpi 300

/Applications/Inkscape.app/Contents/MacOS/inkscape $(PWD)/WorkExperience_PopCap.svg --export-filename=$(PWD)/../latex/WorkExperience_PopCap.pdf --export-type="pdf" --export-text-to-path --export-dpi 300

/Applications/Inkscape.app/Contents/MacOS/inkscape $(PWD)/WorkExperience_Welocalize.svg --export-filename=$(PWD)/../latex/WorkExperience_Welocalize.pdf --export-type="pdf" --export-text-to-path --export-dpi 300

/Applications/Inkscape.app/Contents/MacOS/inkscape $(PWD)/WorkExperience_BowneGlobalSolutions.svg --export-filename=$(PWD)/../latex/WorkExperience_BowneGlobalSolutions.pdf --export-type="pdf" --export-text-to-path --export-dpi 300

/Applications/Inkscape.app/Contents/MacOS/inkscape $(PWD)/WorkExperience_TekTranslation.svg --export-filename=$(PWD)/../latex/WorkExperience_TekTranslation.pdf --export-type="pdf" --export-text-to-path --export-dpi 300
```

## Convert to PNG

```bash
/Applications/Inkscape.app/Contents/MacOS/inkscape $(PWD)/DevOps.svg --export-png=$(PWD)/../latex/DevOps.png
```
