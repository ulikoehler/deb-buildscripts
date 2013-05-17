#!/bin/bash
#$0 <pkg name> <version> <dependencies (comma-separated)> <Description>
export NAME=$1
export VERSION=$2
export DEBVERSION=${VERSION}-1
export DEPENDENCIES=$3
export DESCRIPTION=$4
mkdir -p $NAME
cd $NAME
rm -rf debian
mkdir debian
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create control file
echo "Source: $NAME" > debian/control
echo "Architecture: all" >> debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: main" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Priority: optional" >> debian/control
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Version: $DEBVERSION" >> debian/control
echo "Architecture: all" >> debian/control
echo "Depends: $DEPENDENCIES" >> debian/control
echo "Build-Depends: debhelper (>= 8), devscripts" >> debian/control
echo "Description: $DESCRIPTION" >> debian/control
#Create debuild rules file (metapackage, do nothing)
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\t' >> debian/rules
#Create some misc files
echo "8" > debian/compat
mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format
#Build the package
debuild -us -uc -b
cd ..
rm -rf $NAME