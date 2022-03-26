#!/usr/bin/env bash
for filename in *.svg; do
    /Applications/Inkscape.app/Contents/MacOS/inkscape $(PWD)/$filename --export-filename=$(PWD)/../latex/$(basename "$filename" .svg).pdf --export-type="pdf" --export-text-to-path --export-dpi 300
done
