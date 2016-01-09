#!/bin/bash
export NAME=coturn
export VERSION=4.5.0.3
export DEBVERSION=${VERSION}-1
#Download it
git clone https://github.com/coturn/coturn.git
cd coturn && git checkout 4.5.0.3 && rm -rf .git && cd ..
tar cJvf ${NAME}_${VERSION}.orig.tar.xz coturn
cd coturn
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
echo "Build-Depends: debhelper (>= 8), libevent-dev" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: https://github.com/coturn/coturn.git" >> debian/control
echo "Description: CoTurn TURN server" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tCFLAGS=-march=core2 CXXFLAGS=-march=core2 ./configure --prefix=`pwd`/debian/$NAME/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
