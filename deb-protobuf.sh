#!/bin/bash
export VERSION=2.5.0
export DEBVERSION=2.5.0-1
wget https://protobuf.googlecode.com/files/protobuf-${VERSION}.tar.bz2 -O libprotobuf_${VERSION}.orig.tar.bz2
tar xjvf libprotobuf_${VERSION}.orig.tar.bz2
cd protobuf-${VERSION}
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copyright
#Create the changelog (no messages needed)
dch --create -v $DEBVERSION --package libprotobuf ""
#Create copyright file
cp COPYING.txt debian/copyright
#Create control file
echo "Source: libprotobuf" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: libprotobuf" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Provides: libprotobuf-c0, libprotobuf7, libprotobuf-lite7" >> debian/control
echo "Build-Depends: zlib1g-dev" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, zlib1g" >> debian/control
echo "Homepage: https://code.google.com/p/protobuf/" >> debian/control
echo "Description: Google Protobuf library" >> debian/control
#-dev package
echo "" >> debian/control
echo "Package: libprotobuf-dev" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Provides: libprotobuf-c0, libprotobuf-c0-dev, libprotobuf-dev" >> debian/control
echo "Depends: zlib1g, libprotobuf (= $DEBVERSION)" >> debian/control
echo "Homepage: https://code.google.com/p/protobuf/" >> debian/control
echo "Description: Google Protobuf library & executables (development files)" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t./configure --with-zlib --prefix=`pwd`/debian/libprotobuf/usr' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e '\tmkdir -p debian/libprotobuf-dev/usr' >> debian/rules
echo -e '\tmv debian/libprotobuf/usr/bin debian/libprotobuf/usr/include debian/libprotobuf-dev/usr/' >> debian/rules
#Create the target dir
mkdir -p debian/protobuf/usr
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc