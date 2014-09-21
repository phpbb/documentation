#!/bin/bash

echo "Removing previous PDF"
rm ascraeus_doc.pdf

echo "Creating new PDF"
fop -xml ascraeus_doc.xml -xsl xsl/ascraeus_pdf.xsl -pdf ascraeus_doc.pdf

echo "Done"