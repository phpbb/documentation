@echo off

::Path to FOP
set fop_path=C:\fop

echo Removing previous PDF
del triton_doc.pdf

echo Creating new PDF
%fop_path%\fop -xml triton_doc.xml -xsl xsl\triton_pdf.xsl -pdf triton_doc.pdf

echo Done
