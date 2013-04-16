#!/bin/bash
export NAME=kate-syntax-jade
export VERSION=0.1
export DEBVERSION=${VERSION}-1
git clone https://github.com/RangerMauve/kate-jade-highlighting.git
cd kate-jade-highlighting
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copyright
#Create the changelog (no messages needed)
dch --create -v $DEBVERSION --package $NAME ""
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Homepage: https://github.com/RangerMauve/$NAME" >> debian/control
echo "Description: Jade (http://jade-lang.com/) syntax highlighting for Kate" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t'
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr/share/kde4/apps/katepart/syntax/" >> debian/rules
echo -e "\tcp jade.xml debian/$NAME/usr/share/kde4/apps/katepart/syntax/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b