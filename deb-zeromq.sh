#!/bin/bash
export NAME=libzmq
export VERSION=3.2.3
export DEBVERSION=${VERSION}-2
export URL=http://download.zeromq.org/zeromq-${VERSION}.tar.gz
#Download it
wget "$URL" -O ${NAME}_${VERSION}.orig.tar.gz
tar xzvf ${NAME}_${VERSION}.orig.tar.gz
cd zeromq-${VERSION}
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
echo "Provides: libzmq1"
echo "Build-Depends: debhelper (>= 8), libjemalloc-dev" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: all" >> debian/control
echo "Provides: libzmq1" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libjemalloc1" >> debian/control
echo "Homepage: http://zeromq.org/" >> debian/control
echo "Description: ZeroMQ (0MQ) lightweight messaging kernel" >> debian/control
#-dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: any" >> debian/control
echo "Provides: libzmq-dev" >> debian/control
echo "Depends: libzmq (= $DEBVERSION)" >> debian/control
echo "Homepage: http://zeromq.org/" >> debian/control
echo "Description: ZeroMQ (0MQ) lightweight messaging kernel (development headers)" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tLDFLAGS=-ljemalloc ./configure --prefix=`pwd`/debian/${NAME}/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr" >> debian/rules
echo -e "\tmv debian/$NAME/usr/include debian/$NAME-dev/usr/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc