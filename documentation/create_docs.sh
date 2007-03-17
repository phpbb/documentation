#!/bin/bash

# set this to the correct path
path="../website/support/documentation/3.0"

echo "Removing build directory"
rm -rf build

xsltproc --xinclude xsl/olympus_php.xsl olympus_doc.xml

#echo "Copying style.css to $path/"
#cp style.css $path/
if [ "$?" == "0" ]; then
	echo "Successfully create documentation"
	echo "Removing $path"
	rm -rf $path
	echo "Copying documentation to $path"
	cp -r build $path
	echo "Creating directory $path/images"
	mkdir $path/images
	echo "Copying images/* to $path/images/"
	cp -r images/* $path/images/
else
	echo "Failed creating documentation"
fi