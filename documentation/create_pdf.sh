#!/bin/bash

echo "Removing previous PDF"
rm olympus_doc.pdf

echo "Creating new PDF"
fop -xml olympus_doc.xml -xsl xsl/olympus_pdf.xsl -pdf olympus_doc.pdf

echo "Done"