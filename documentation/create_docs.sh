#!/bin/bash

# set this to the correct path
path=${1:-'/var/www/phpbb.com/htdocs/support/documentation/3.3'}

echo "Removing build directory"
rm -rf build

echo "Creating docs"
xsltproc --xinclude xsl/proteus_php.xsl proteus_doc.xml
exit_code=$?  # Capture the exit code

if [ "$exit_code" == "0" ]; then
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

# Output exit code
exit $exit_code
