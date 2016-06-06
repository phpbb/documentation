#!/bin/bash

echo "Removing previous PDF"
rm rhea_doc.pdf

echo "Creating new PDF"
fop -xml rhea_doc.xml -xsl xsl/rhea_pdf.xsl -pdf rhea_doc.pdf

echo "Done"