#!/bin/bash

if [ "$1" != "-run" ]; then
	echo "Read this script before executing it, it's potentially dangerous (removes folders)"
	echo "use 'create_docs.sh -run' to avoid this message"
	exit
fi

# set this to the correc path
path="../website/support/documentation/3.0"

echo "Removing $path"
rm -rf $path

xsltproc --xinclude xsl/olympus_php.xsl olympus_doc.xml

#echo "Copying style.css to $path/"
#cp style.css $path/
echo "Creating directory $path/images"
mkdir $path/images
echo "Copying images/* to $path/images/"
cp -r images/* $path/images/