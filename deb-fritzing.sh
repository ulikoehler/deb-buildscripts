#!/bin/bash
export NAME=fritzing
export VERSION=0.8.5b
export DEBVERSION=${VERSION}-1
export URL=http://fritzing.org/download/${VERSION}/source-tarball/fritzing-${VERSION}.source.tar.bz2
#Download it
if [ ! -f ${NAME}_${VERSION}.orig.tar.bz2 ] ; then
    wget "$URL" -O ${NAME}_${VERSION}.orig.tar.bz2
fi
tar xjvf ${NAME}_${VERSION}.orig.tar.bz2
cd fritzing-${VERSION}.source
rm -rf debian
mkdir -p debian
#Use the existing COPYING file
cp LICENSE.GPL3 debian/copyright
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
echo "Build-Depends: debhelper (>= 8), libqt4-dev" >> debian/control
#Main package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://fritzing.org/" >> debian/control
echo "Description: Fritzing" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tqmake PREFIX=`pwd`/debian/${NAME}/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j2' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
