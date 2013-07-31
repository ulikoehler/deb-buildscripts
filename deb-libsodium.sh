#!/bin/bash
export NAME=libsodium
export VERSION=0.4.2
export DEBVERSION=${VERSION}-2
#Download and extract the archive
if [ ! -f ${NAME}_${VERSION}.orig.tar.gz ]
then
    wget "https://download.libsodium.org/libsodium/releases/${NAME}-${VERSION}.tar.gz" -O ${NAME}_${VERSION}.orig.tar.gz
fi
tar xzvf ${NAME}_${VERSION}.orig.tar.gz
cd ${NAME}-${VERSION}
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
echo "Build-Depends: debhelper (>= 8), devscripts, build-essential" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libsodium(= $DEBVERSION)" >> debian/control
echo "Homepage: https://libsodium.org" >> debian/control
echo "Description: libsodium" >> debian/control
#dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: all" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: https://libsodium.org" >> debian/control
echo "Description: libsodium development files" >> debian/control
#Rules files
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t./configure --prefix=$(pwd)/debian/$NAME/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr debian/$NAME-dev/usr" >> debian/rules
echo -e "\tmake install" >> debian/rules
echo -e "\tmv debian/$NAME/usr/include debian/$NAME-dev/usr" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc