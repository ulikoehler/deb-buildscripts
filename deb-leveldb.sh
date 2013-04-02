#!/bin/bash
wget https://leveldb.googlecode.com/files/leveldb-1.9.0.tar.gz
mv leveldb-1.9.0.tar.gz libleveldb_1.9.0.orig.tar.gz
tar xzvf libleveldb_1.9.0.orig.tar.gz
cd leveldb-1.9.0
rm -rf debian
mkdir -p debian
#Use the existing LICENSE file
cp LICENSE debian/copying
#Create the changelog (dummy only, doesn't contain real changelog messages)
dch --create -v 1.9.0-1 --package libleveldb ""
#Create control file
echo "Source: libleveldb" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8), libsnappy-dev (>= 1.0)" >> debian/control
#Create the library package
echo "" >> debian/control
echo "Package: libleveldb" >> debian/control
echo "Version: 1.9.0-1" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libsnappy1 (>= 1.0)" >> debian/control
echo "Homepage: https://code.google.com/p/leveldb/" >> debian/control
echo "Description: LevelDB Key-Value database" >> debian/control
#Also create the -dev package
echo "" >> debian/control
echo "Package: libleveldb-dev" >> debian/control
echo "Version: 1.9.0-1" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: libsnappy-dev (>= 1.0)" >> debian/control
echo "Homepage: https://code.google.com/p/leveldb/" >> debian/control
echo "Description: LevelDB Key-Value database (development files)" >> debian/control
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
echo -e '\tmkdir -p debian/libleveldb/usr/lib debian/libleveldb-dev/usr/include' >> debian/rules
echo -e '\tcp --preserve=links libleveldb.* debian/libleveldb/usr/lib' >> debian/rules
echo -e '\tcp -r include/leveldb debian/libleveldb-dev/usr/include/' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
debuild -us -uc