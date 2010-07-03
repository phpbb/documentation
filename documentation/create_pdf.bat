@echo off

::Path to FOP
set fop_path=C:\fop-0.95

echo Removing previous PDF
del olympus_doc.pdf

echo Creating new PDF
%fop_path%\fop -xml olympus_doc.xml -xsl xsl\olympus_pdf.xsl -pdf olympus_doc.pdf

echo Done