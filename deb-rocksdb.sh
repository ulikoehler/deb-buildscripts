#!/bin/bash
#It's not sufficient to only update these variables once a new version has been released!

#Download and extract LevelDB
git clone git://github.com/facebook/rocksdb.git
cd rocksdb
export VERSION=1.0-git$(git rev-list --all | wc -l)
export DEBVERSION=${VERSION}-1
rm -rf debian
mkdir -p debian
#Use the existing LICENSE file
cp LICENSE debian/copyright
#Create the changelog (dummy only, doesn't contain real changelog messages)
dch --create -v $DEBVERSION --package librocksdb ""
#Create control file
echo "Source: librocksdb" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8), libsnappy-dev (>= 1.0), libgflags-dev, libjemalloc-dev" >> debian/control
#Create the library package
echo "" >> debian/control
echo "Package: librocksdb" >> debian/control
echo "Version: $DEBVERSION" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libsnappy1 (>= 1.0), libjemalloc1" >> debian/control
echo "Homepage: http://rocksdb.org/" >> debian/control
echo "Description: RocksDB Key-Value database" >> debian/control
#Also create the -dev package
echo "" >> debian/control
echo "Package: librocksdb-dev" >> debian/control
echo "Version: $DEBVERSION" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: libsnappy-dev (>= 1.0), libleveldb (>= ${VERSION})" >> debian/control
echo "Homepage: http://rocksdb.org/" >> debian/control
echo "Description: RocksDB Key-Value database (development files)" >> debian/control
#Also create the -doc package
echo "" >> debian/control
echo "Package: librocksdb-doc" >> debian/control
echo "Version: $DEBVERSION" >> debian/control
echo "Architecture: any" >> debian/control
echo "Recommends: librocksdb-dev (>= $VERSION), librocksdb (>= $VERSION)" >> debian/control
echo "Homepage: http://rocksdb.org/" >> debian/control
echo "Description: RocksDB Key-Value database (documentation)" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\tsed -i "s/tcmalloc/jemalloc/g" build_tools/build_detect_platform' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rule
echo -e '\tCCFLAGS="-march=core2" CXXFLAGS="-march=core2" make' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/librocksdb/usr/lib debian/librocksdb-dev/usr/include debian/libleveldb-doc/usr/share/doc/librocksdb' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
debuild -us -uc -b
