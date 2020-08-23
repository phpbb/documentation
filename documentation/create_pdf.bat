@echo off

::Path to FOP
set fop_path=C:\fop

echo Removing previous PDF
del proteus_doc.pdf

echo Creating new PDF
%fop_path%\fop -xml proteus_doc.xml -xsl xsl\proteus_pdf.xsl -pdf proteus_doc.pdf

echo Done
