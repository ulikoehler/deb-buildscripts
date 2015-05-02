#!/bin/bash
#It's not sufficient to only update these variables once a new version has been released!

#Download and extract LevelDB
git clone git://github.com/facebook/rocksdb.git
cd rocksdb
export VERSION=3.10.1
git checkout rocksdb-$VERSION
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
echo "Build-Depends: debhelper (>= 8), libsnappy-dev (>= 1.0), libgflags-dev, libjemalloc-dev, libbz2-dev, zlib1g-dev" >> debian/control
#Create the library package
echo "" >> debian/control
echo "Package: librocksdb" >> debian/control
echo "Version: $DEBVERSION" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libsnappy1 (>= 1.0), libjemalloc1, libbz2-1.0, zlib1g" >> debian/control
echo "Homepage: http://rocksdb.org/" >> debian/control
echo "Description: RocksDB Key-Value database" >> debian/control
#Also create the -dev package
echo "" >> debian/control
echo "Package: librocksdb-dev" >> debian/control
echo "Version: $DEBVERSION" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: libsnappy-dev (>= 1.0), librocksdb (>= ${VERSION})" >> debian/control
echo "Homepage: http://rocksdb.org/" >> debian/control
echo "Description: RocksDB Key-Value database (development files)" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\tsed -i "s/tcmalloc/jemalloc/g" build_tools/build_detect_platform' >> debian/rules
#Compatibility for older g++
echo -e '\tsed -i "s/gnu++11/gnu++0x/g" build_tools/build_detect_platform' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rule
echo -e '\tCCFLAGS="-march=core2" CXXFLAGS="-march=core2" make all librocksdb.so' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j4 shared_lib' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/librocksdb/usr/lib debian/librocksdb/usr/bin debian/librocksdb-dev/usr/include ' >> debian/rules
echo -e '\tcp -r include/* debian/librocksdb-dev/usr/include ' >> debian/rules
echo -e '\tcp *.so debian/librocksdb/usr/lib' >> debian/rules
echo -e '\tcp ldb debian/librocksdb/usr/bin' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
debuild -us -uc -b
