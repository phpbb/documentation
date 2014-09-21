#!/bin/bash

# set this to the correct path
path="/var/www/phpbb.com/htdocs/support/documentation/3.1"

echo "Removing build directory"
rm -rf build

echo "Creating docs"
xsltproc --xinclude xsl/ascraeus_php.xsl ascraeus_doc.xml

if [ "$?" == "0" ]; then
	echo "Successfully created documentation"
	echo "Removing $path"
	rm -rf $path
	echo "Copying documentation to $path"
	cp -r build $path
	echo "Creating directory $path/images"
	mkdir $path/images
	echo "Copying images/* to $path/images/"
	cp -r content/en/images/* $path/images/
	echo "Making documentation directory group writable"
	chmod g+w -R $path
else
	echo "Failed creating documentation"
fi