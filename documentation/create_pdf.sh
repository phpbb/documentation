#!/bin/bash

echo "Removing previous PDF"
if [ -f triton_doc.pdf ]; then
  rm triton_doc.pdf
fi

echo "Creating new PDF"
fop -xml triton_doc.xml -xsl xsl/triton_pdf.xsl -pdf triton_doc.pdf

echo "Done"
