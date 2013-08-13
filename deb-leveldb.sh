#!/bin/bash
#It's not sufficient to only update these variables once a new version has been released!
export VERSION=1.12.0
export DEBVERSION=${VERSION}-7
#Download and extract LevelDB
wget https://leveldb.googlecode.com/files/leveldb-${VERSION}.tar.gz
mv leveldb-${VERSION}.tar.gz libleveldb_${VERSION}.orig.tar.gz
tar xzvf libleveldb_${VERSION}.orig.tar.gz
cd leveldb-${VERSION}
rm -rf debian
mkdir -p debian
#Use the existing LICENSE file
cp LICENSE debian/copyright
#Create the changelog (dummy only, doesn't contain real changelog messages)
dch --create -v $DEBVERSION --package libleveldb ""
#Create control file
echo "Source: libleveldb" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8), libsnappy-dev (>= 1.0), libjemalloc-dev" >> debian/control
#Create the library package
echo "" >> debian/control
echo "Package: libleveldb" >> debian/control
echo "Version: $DEBVERSION" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libsnappy1 (>= 1.0), libjemalloc1" >> debian/control
echo "Homepage: https://code.google.com/p/leveldb/" >> debian/control
echo "Description: LevelDB Key-Value database" >> debian/control
#Also create the -dev package
echo "" >> debian/control
echo "Package: libleveldb-dev" >> debian/control
echo "Version: $DEBVERSION" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: libsnappy-dev (>= 1.0), libleveldb (>= ${VERSION})" >> debian/control
echo "Homepage: https://code.google.com/p/leveldb/" >> debian/control
echo "Description: LevelDB Key-Value database (development files)" >> debian/control
#Also create the -doc package
echo "" >> debian/control
echo "Package: libleveldb-doc" >> debian/control
echo "Version: $DEBVERSION" >> debian/control
echo "Architecture: any" >> debian/control
echo "Recommends: libleveldb-dev (>= $VERSION), libleveldb (>= $VERSION)" >> debian/control
echo "Homepage: https://code.google.com/p/leveldb/" >> debian/control
echo "Description: LevelDB Key-Value database (development files)" >> debian/control
#Create postinst script to create symlinks
echo "ln -sf /usr/lib/libleveldb.so.1.12 /usr/lib/libleveldb.so.1" > debian/libleveldb.postinst
echo "ln -sf /usr/lib/libleveldb.so.1 /usr/lib/libleveldb.so" >> debian/libleveldb.postinst
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tsed -i "s/tcmalloc/jemalloc/g" build_detect_platform' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/libleveldb/usr/lib debian/libleveldb-dev/usr/include debian/libleveldb-doc/usr/share/doc/libleveldb' >> debian/rules
echo -e '\tcp libleveldb.so.1.12 libleveldb.a debian/libleveldb/usr/lib' >> debian/rules
echo -e '\tcp -r include/leveldb debian/libleveldb-dev/usr/include/' >> debian/rules
echo -e '\tcp -r doc/* debian/libleveldb-doc/usr/share/doc/libleveldb' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
debuild -us -uc
