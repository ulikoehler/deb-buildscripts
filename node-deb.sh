#!/bin/bash
#sudo apt-get install devscripts
export VERSION=0.10.0
#Compile
wget http://nodejs.org/dist/v0.10.0/node-v${VERSION}.tar.gz
mv node-v${VERSION}.tar.gz nodejs_${VERSION}.orig.tar.gz
tar xzf nodejs_${VERSION}.orig.tar.gz
cd node-v${VERSION}
#Create stuff
mkdir debian
#Use the LICENSE file from nodejs as copying file
cp LICENSE debian/copying
#Create the changelog (no messages needed)
dch --create -v ${VERSION}-wspot --package nodejs ""
#Create control file
echo "Source: nodejs" > debian/control
echo "Package: nodejs" >> debian/control
echo "Version: ${VERSION}-wspot" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Maintainer: btronik <ukoehler@btronik.de>" >> debian/control
echo "Depends: libc6 (>= 2.6), libssl1.0.0 (>= 1.0.1), libstdc++6 (>= 4.1.1), zlib1g (>= 1:1.1.4)" >> debian/control
echo "Section: web" >> debian/control
echo "Priority: extra" >> debian/control
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
