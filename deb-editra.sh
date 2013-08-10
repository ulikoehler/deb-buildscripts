#!/bin/bash
export NAME=editra
export VERSION=0.7.20
export DEBVERSION=${VERSION}-1
export URL=http://editra.org/uploads/src/Editra-${VERSION}.tar.gz
#Download it
wget "$URL" -O ${NAME}_${VERSION}.orig.tar.gz
tar xzvf ${NAME}_${VERSION}.orig.tar.gz
cd Editra-${VERSION}
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
echo "Build-Depends: debhelper (>= 8), python" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: all" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: https://editra.org/" >> debian/control
echo "Description: Editra editor" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr" >> debian/rules
echo -e "\tpython setup.py install --prefix=debian/$NAME/usr" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc