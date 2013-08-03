#!/bin/bash
#Revision 1
#Libsodium DEB build script. Call without arguments.
#(c)2013 Uli Koehler. Licensed as CC-By-SA 3.0 DE.
export NAME=goaccess
export VERSION=0.6
export DEBVERSION=1:${VERSION}-1
#Download and extract the archive
if [ ! -f ${NAME}_${VERSION}.orig.tar.gz ]
then
    wget "http://downloads.sourceforge.net/project/goaccess/0.6/goaccess-0.6.tar.gz?r=http%3A%2F%2Fgoaccess.prosoftcorp.com%2Fdownload&ts=1375541063&use_mirror=switch" -O ${NAME}_${VERSION}.orig.tar.gz
fi
tar xzvf ${NAME}_${VERSION}.orig.tar.gz
cd ${NAME}-${VERSION}
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
echo "Build-Depends: debhelper (>= 8), devscripts, build-essential" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://goaccess.prosoftcorp.com/" >> debian/control
echo "Description: GoAccess - Visual Web Log Analyzer" >> debian/control
#Rules files
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t./configure --prefix=$(pwd)/debian/$NAME/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr" >> debian/rules
echo -e "\tmake install" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
