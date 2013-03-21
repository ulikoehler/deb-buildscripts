#!/bin/bash
tar xzvf thttpd_2.25b.orig.tar.gz
cd thttpd-2.25b
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v 2.25b-1 --package thttpd ""
#Create control file
echo "Source: thttpd" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: thttpd" >> debian/control
echo "Version: 2.25b-1" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Depends: libc6 (>= 2.4)" >> debian/control
echo "Homepage: http://acme.com/software/thttpd/" >> debian/control
echo "Description: Node.js WOTSPOT distribution" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t./configure' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/thttpd/usr/bin' >> debian/rules
echo -e '\tcp thttpd debian/thttpd/usr/bin' >> debian/rules
#Create some misc files
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
debuild -us -uc