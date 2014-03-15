#!/bin/bash
export NAME=libjemalloc
export VERSION=3.5.1
export DEBVERSION=${VERSION}-1
export URL=http://www.canonware.com/download/jemalloc/jemalloc-${VERSION}.tar.bz2
#Download it
wget "$URL" -O ${NAME}_${VERSION}.orig.tar.bz2
tar xjvf ${NAME}_${VERSION}.orig.tar.bz2
cd jemalloc-${VERSION}
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
echo "Package: libjemalloc1" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://www.canonware.com/jemalloc/" >> debian/control
echo "Description: JeMalloc Memory allocator" >> debian/control
#-dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: all" >> debian/control
echo "Homepage: http://www.canonware.com/jemalloc/" >> debian/control
echo "Description: JeMalloc Memory allocator" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tCFLAGS=-march=core2 CXXFLAGS=-march=core2 ./configure --prefix=`pwd`/debian/libjemalloc1/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr" >> debian/rules
echo -e "\tmv debian/libjemalloc1/usr/include debian/$NAME-dev/usr/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
