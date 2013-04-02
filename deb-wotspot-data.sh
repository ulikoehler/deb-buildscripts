#!/bin/bash
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v 1.0-1 --package wotspot-testdata-shop ""
#Create copyright file
touch debian
#Create control file
echo "Source: wotspot-testdata-shop" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: wotspot-testdata-shop" >> debian/control
echo "Architecture: all" >> debian/control
echo "Provides: wotspot-data" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
#Create rules file
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
echo -e '\tmkdir -p debian/wotspot-testdata-shop/opt/wotspot' >> debian/rules
echo -e '\tcp shopdata shopstatic -r debian/wotspot-testdata-shop/opt/wotspot' >> debian/rules
#Create some misc files
echo "8" > debian/compat
mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format
#Build the package
debuild -us -uc -b