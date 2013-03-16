#!/bin/bash
mkdir debian
#Use the LICENSE file from nodejs as copying file
cp LICENSE debian/copying
#Create the changelog (no messages needed)
dch --create -v ${VERSION}-wspot --package nodejs ""
#Create control file
echo "Source: nodejs" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control

echo "Package: nodejs" >> debian/control
#echo "Version: ${VERSION}-wspot" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Depends: libc6 (>= 2.6), libssl1.0.0 (>= 1.0.1), libstdc++6 (>= 4.1.1), zlib1g (>= 1:1.1.4)" >> debian/control
echo "Homepage: http://nodejs.org/" >> debian/control
echo "Description: Node.js WOTSPOT distribution" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format