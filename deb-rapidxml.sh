#!/bin/bash
wget -O rapidxml-1.13.zip "http://downloads.sourceforge.net/project/rapidxml/rapidxml/rapidxml%201.13/rapidxml-1.13.zip?r=http%3A%2F%2Frapidxml.sourceforge.net%2F&ts=1364493742&use_mirror=garr"
unzip rapidxml-1.13.zip
tar cjvf librapidxml-dev_1.13.orig.tar.bz2 rapidxml-1.13
cd rapidxml-1.13
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
cp license.txt debian/copyright
#Create the changelog (no messages needed)
dch --create -v 1.13-1 --package librapidxml-dev ""
#Create control file
echo "Source: librapidxml-dev" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: librapidxml-dev" >> debian/control
echo "Architecture: any" >> debian/control
echo "Homepage: rapidxml.sourceforge.net" >> debian/control
echo "Description: RapidXML fast XML parser (header-only library, includes docs)" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t'
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/librapidxml-dev/usr/include/rapidxml' >> debian/rules
echo -e '\tmkdir -p debian/librapidxml-dev/usr/share/doc/librapidxml-dev' >> debian/rules
echo -e '\tcp -r *.hpp debian/librapidxml-dev/usr/include/rapidxml' >> debian/rules
echo -e '\tcp -r manual.html debian/librapidxml-dev/usr/share/doc/librapidxml-dev' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc