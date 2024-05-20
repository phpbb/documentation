#!/bin/bash

echo "Removing previous PDF"
rm proteus_doc.pdf

echo "Creating new PDF"
fop -xml proteus_doc.xml -xsl xsl/proteus_pdf.xsl -pdf proteus_doc.pdf

echo "Done"
