#!/bin/bash
git clone https://github.com/facebook/zstd.git
export NAME=zstd
export VERSION=1.1.0
export DEBVERSION=${VERSION}-1
#Download it
(cd zstd && rm -rf .git && cd ..)
tar cJvf ${NAME}_${VERSION}.orig.tar.xz zstd
cd zstd
rm -rf debian
mkdir -p debian
#Use the existing COPYING file
cp LICENSE debian/copyright
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create copyright file
cp LICENSE debian/copyright
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
#Main package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: https://github.com/facebook/zstd" >> debian/control
echo "Description: ZSTD compression (executable)" >> debian/control
#Main package
echo "" >> debian/control
echo "Package: lib$NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: https://github.com/facebook/zstd" >> debian/control
echo "Description: ZSTD compression (library)" >> debian/control
#Main package
echo "" >> debian/control
echo "Package: lib$NAME-dev" >> debian/control
echo "Architecture: all" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libzstd (= $DEBVERSION)" >> debian/control
echo "Homepage: https://github.com/facebook/zstd" >> debian/control
echo "Description: ZSTD compression (development files)" >> debian/control
#Rules files
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr debian/lib$NAME-dev/usr debian/lib$NAME/usr" >> debian/rules
echo -e "\tmake install PREFIX=../debian/$NAME/usr" >> debian/rules
echo -e "\tmv debian/$NAME/usr/lib debian/lib$NAME/usr/" >> debian/rules
echo -e "\tmv debian/$NAME/usr/include debian/lib$NAME-dev/usr/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
