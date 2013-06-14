#!/bin/bash
export NAME=libftdi
export VERSION=1.0
export DEBVERSION=${VERSION}-1
export URL="http://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.0.tar.bz2"
#Download it
if [ ! -f "${NAME}_${VERSION}.orig.tar.bz2" ]
then
    wget "$URL" -O ${NAME}_${VERSION}.orig.tar.bz2
fi
tar xjvf ${NAME}_${VERSION}.orig.tar.bz2
cd libftdi1-${VERSION}
rm -rf debian
mkdir -p debian
#Use the existing COPYING file
touch debian/copyright
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
echo "Build-Depends: debhelper (>= 8), cmake " >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://www.intra2net.com/en/developer/libftdi/" >> debian/control
echo "Description: libftdi" >> debian/control
#Dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://www.intra2net.com/en/developer/libftdi/" >> debian/control
echo "Description: libftdi" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tcmake -DCMAKE_INSTALL_PREFIX:PATH==`pwd`/debian/${NAME}/usr ." >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr" >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmv debian/$NAME/usr/include debian/$NAME-dev/usr/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
