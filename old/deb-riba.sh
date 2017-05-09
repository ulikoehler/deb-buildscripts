#!/bin/bash
export VERSION=0.1
export DEBVERSION=${VERSION}-1

cd Riba
#Clear and re-create the debian directory
rm -rf debian
mkdir -p debian
#Use the existing LICENSE file
cp license.txt debian/copyright
#Create the changelog (dummy only, doesn't contain real changelog messages)
dch --create -v $DEBVERSION --package riba ""
#Create control file
echo "Source: riba" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8), libleveldb-dev (>= 1.0), bison, flex, libreadline-dev" >> debian/control
#Create the library package
echo "" >> debian/control
echo "Package: riba" >> debian/control
echo "Version: $DEBVERSION" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libleveldb, libsnappy1, libreadline, libstdc++6, libc6" >> debian/control
echo "Homepage: https://code.google.com/p/leveldb/" >> debian/control
echo "Description: LevelDB Key-Value database" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/riba/usr/bin' >> debian/rules
echo -e '\tcp riba debian/riba/usr/bin' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
debuild -us -uc -b