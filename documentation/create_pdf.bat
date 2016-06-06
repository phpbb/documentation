@echo off

::Path to FOP
set fop_path=C:\fop

echo Removing previous PDF
del rhea_doc.pdf

echo Creating new PDF
%fop_path%\fop -xml rhea_doc.xml -xsl xsl\rhea_pdf.xsl -pdf rhea_doc.pdf

echo Done