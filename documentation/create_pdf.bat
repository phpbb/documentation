@echo off

::Path to FOP
set fop_path=C:\fop

echo Removing previous PDF
del ascraeus_doc.pdf

echo Creating new PDF
%fop_path%\fop -xml ascraeus_doc.xml -xsl xsl\ascraeus_pdf.xsl -pdf ascraeus_doc.pdf

echo Done