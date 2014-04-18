#!/bin/bash
export NAME=libczmq
export VERSION=2.1.0
export DEBVERSION=${VERSION}-1
export URL=http://download.zeromq.org/czmq-${VERSION}.tar.gz
#Download it
wget "$URL" -O ${NAME}_${VERSION}.orig.tar.gz
tar xzvf ${NAME}_${VERSION}.orig.tar.gz
cd czmq-${VERSION}
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
echo "Build-Depends: debhelper (>= 8), libzmq-dev, libjemalloc-dev" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Provides: libczmq1" >> debian/control
echo "Replaces: libczmq" >> debian/control
echo "Conflicts: libczmq" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libzmq (>= 3.0), libjemalloc1" >> debian/control
echo "Homepage: http://czmq.zeromq.org/" >> debian/control
echo "Description: ZeroMQ (0MQ) lightweight messaging kernel CZMQ High-Level C-Binding" >> debian/control
#-dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: all" >> debian/control
echo "Provides: libczmq-dev" >> debian/control
echo "Replaces: libczmq-dev" >> debian/control
echo "Conflicts: libczmq-dev" >> debian/control
echo "Depends: libzmq-dev (>= 3.0), libczmq (= $DEBVERSION), " >> debian/control
echo "Homepage: http://czmq.zeromq.org/" >> debian/control
echo "Description: ZeroMQ (0MQ) lightweight messaging kernel CZMQ High-Level C-Binding (development headers)" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tLDFLAGS=-ljemalloc ./configure --prefix=`pwd`/debian/${NAME}/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
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

