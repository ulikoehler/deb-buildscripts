#!/bin/bash
export NAME=libsnappy
export VERSION=1.1.0
export DEBVERSION=${VERSION}-2
export URL=https://snappy.googlecode.com/files/snappy-1.1.0.tar.gz
#Download it
wget "$URL" -O ${NAME}_${VERSION}.orig.tar.gz
tar xzvf ${NAME}_${VERSION}.orig.tar.gz
cd snappy-${VERSION}
rm -rf debian
mkdir -p debian
#Use the existing COPYING file
cp COPYING debian/copyright
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create copyright file
cp COPYING debian/copyright
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: libsnappy1" >> debian/control
echo "Architecture: all" >> debian/control
echo "Provides: libsnappy1" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libjemalloc1" >> debian/control
echo "Homepage: https://code.google.com/p/snappy/" >> debian/control
echo "Description: Snappy compression library" >> debian/control
#-dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: any" >> debian/control
echo "Provides: libsnappy-dev" >> debian/control
echo "Depends: libsnappy1 (= $DEBVERSION)" >> debian/control
echo "Homepage: https://code.google.com/p/snappy/" >> debian/control
echo "Description: Snappy compression library" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t./configure --prefix=`pwd`/debian/libsnappy1/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/libsnappy1/usr" >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr" >> debian/rules
echo -e "\tmv debian/libsnappy1/usr/include debian/$NAME-dev/usr/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc