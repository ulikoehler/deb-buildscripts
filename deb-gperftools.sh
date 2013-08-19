#!/bin/bash
export NAME=google-perftools
export VERSION=2.1
#Download it
export DEBVERSION=${VERSION}-1
wget https://gperftools.googlecode.com/files/gperftools-2.1.zip
unzip gperftools-2.1.zip
tar cJvf ${NAME}_${VERSION}.orig.tar.xz gperftools-2.1
cd gperftools-2.1
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
#Main package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Provides: libtcmalloc-minimal4" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: https://code.google.com/p/gperftools/" >> debian/control
echo "Description: Google Perftools" >> debian/control
#Dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, gperftools (= $DEBVERSION)" >> debian/control
echo "Homepage: https://code.google.com/p/gperftools/" >> debian/control
echo "Description: Google Perftools" >> debian/control
#Rules files
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t./configure --prefix=$(pwd)/debian/$NAME/usr/" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr/" >> debian/rules
echo -e "\tmake install" >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr/" >> debian/rules
echo -e "\tmv debian/$NAME/usr/include debian/$NAME-dev/usr/include " >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc