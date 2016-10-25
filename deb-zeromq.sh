#!/bin/bash
export NAME=libzmq4
export VERSION=4.1.5
export DEBVERSION=${VERSION}-1
export URL=https://github.com/zeromq/zeromq4-1/releases/download/v${VERSION}/zeromq-${VERSION}.tar.gz
#Download it
wget "$URL" -O ${NAME}_${VERSION}.orig.tar.gz
rm -rf zeromq-${VERSION}
tar xzvf ${NAME}_${VERSION}.orig.tar.gz
cd zeromq-${VERSION}
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
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Provides: libzmq1, libzmq3" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libsodium" >> debian/control
echo "Homepage: http://zeromq.org/" >> debian/control
echo "Description: ZeroMQ (0MQ) lightweight messaging kernel" >> debian/control
#-dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: all" >> debian/control
echo "Provides: libzmq-dev, libzmq1-dev, libzmq3-dev" >> debian/control
echo "Depends: $NAME (= $DEBVERSION)" >> debian/control
echo "Homepage: http://zeromq.org/" >> debian/control
echo "Description: ZeroMQ (0MQ) lightweight messaging kernel (development headers)" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t./configure --prefix=`pwd`/debian/${NAME}/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e '\ttrue' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr" >> debian/rules
echo -e "\tmv debian/$NAME/usr/include debian/$NAME-dev/usr/" >> debian/rules
#Download cppzmq
echo -e "\twget -P debian/$NAME-dev/usr/include https://raw.githubusercontent.com/zeromq/cppzmq/master/zmq.hpp" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
