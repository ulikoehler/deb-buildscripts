#!/bin/bash
export NAME=libfusekit-dev
export VERSION=0.6.5
export DEBVERSION=${VERSION}-1
export URL=https://fusekit.googlecode.com/files/fusekit-${VERSION}.tar.gz
#Download it
wget "$URL" -O ${NAME}_${VERSION}.orig.tar.gz
tar xzvf ${NAME}_${VERSION}.orig.tar.gz
cd fusekit-${VERSION}
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
#-dev package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: libfuse-dev" >> debian/control
echo "Homepage: https://code.google.com/p/fusekit/" >> debian/control
echo "Description: FUSEKit FUSE C++ Wrapper ([header-only] development headers)" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t./configure --prefix=`pwd`/debian/${NAME}/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc