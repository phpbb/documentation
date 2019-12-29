#!/bin/bash

echo "Removing previous PDF"
rm rhea_doc.pdf

echo "Creating new PDF"
fop -xml rhea_33_doc.xml -xsl xsl/rhea_33_pdf.xsl -pdf rhea_33_doc.pdf

echo "Done"
