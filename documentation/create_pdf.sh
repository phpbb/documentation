#!/bin/bash

echo "Removing previous PDF"
if [ -f proteus_doc.pdf ]; then
  rm proteus_doc.pdf
fi

echo "Creating new PDF"
fop -xml proteus_doc.xml -xsl xsl/proteus_pdf.xsl -pdf proteus_doc.pdf

echo "Done"
