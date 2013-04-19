#!/bin/bash
export VERSION=1.1
export DEBVERSION=${VERSION}-1
export NAME=boost-log

if [ ! -d "boost-log-${VERSION}" ]; then
	wget "http://downloads.sourceforge.net/project/boost-log/boost-log-1.1.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fboost-log%2F&ts=1365373752&use_mirror=switch" -O ${NAME}_${VERSION}.zip
	unzip ${NAME}_${VERSION}.zip
	tar cJvf ${NAME}_${VERSION}.orig.tar.xz boost-log-${VERSION}
fi
cd boost-log-${VERSION}
#Build DEB
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v ${DEBVERSION} --package $NAME ""
#Create copyright file
touch debian
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: boost-all" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Description: Boost Log Library" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\t./b2 --prefix=`pwd`/debian/boost-all/usr/' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/boost-all/usr' >> debian/rules
echo -e '\t./b2 --prefix=`pwd`/debian/boost-all/usr/ install' >> debian/rules
#Create some misc files
echo "8" > debian/compat
mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format
#Build the package
debuild -us -uc