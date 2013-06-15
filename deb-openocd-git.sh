#!/bin/bash
export NAME=openocd
#Download it
git clone --depth 1 git://git.code.sf.net/p/openocd/code openocd
cd openocd
export VERSION=0.7.1-git$(git rev-parse HEAD | cut -c 1-10)
export DEBVERSION=${VERSION}-1
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
echo "Build-Depends: debhelper (>= 8), libftdi-dev" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://openocd.sourceforge.net" >> debian/control
echo "Description: OpenOCD Debugger (vanilla, btronik)" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t./configure --prefix=`pwd`/debian/${NAME}/usr --enable-maintainer-mode --enable-ft2232_libftdi --enable-stlink --enable-jlink --enable-buspirate --enable-usbprog" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr" >> debian/rules
#echo -e "\tmv debian/$NAME/usr/include debian/$NAME-dev/usr/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b
