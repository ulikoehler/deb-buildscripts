#!/bin/bash
export NAME=stlink
git clone git://github.com/stlink-org/stlink.git --depth 1 -b v1.7.0
export VERSION=1.7.0
export DEBVERSION=${VERSION}-1
cd stlink
git pull
rm -rf debian
mkdir -p debian/$NAME
#Use the LICENSE file from nodejs as copying file
touch debian/copyright
#Create the changelog (no messages needed)
dch --create -v $DEBVERSION --package stlink ""
#Create copyright file
cp LICENSE debian/copyright
#Create control file
echo "Source: stlink" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8), libusb-1.0-0-dev" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: stlink" >> debian/control
echo "Architecture: any" >> debian/control
echo "Provides: st-flash" >> debian/control
echo 'Depends: ${shlibs:Depends}, ${misc:Depends}, udev' >> debian/control
echo "Homepage: https://github.com/texane/stlink/" >> debian/control
echo "Description: Texane STLink Linux port" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tcmake -DCMAKE_INSTALL_PREFIX:PATH=`pwd`/debian/$NAME/usr -DSTLINK_MODPROBED_DIR:PATH=`pwd`/debian/$NAME/etc/modprobe.d -DSTLINK_UDEV_RULES_DIR:PATH=`pwd`/debian/$NAME/etc/udev/rules.d" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/stlink/etc/udev/rules.d debian/etc/modprobe.d" >> debian/rules
echo -e "\tcp config/udev/rules.d/49-stlink* debian/$NAME/etc/udev/rules.d/" >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tcp config/udev/rules.d/49-stlink* debian/$NAME/etc/udev/rules.d/" >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e >> debian/rules
#Create the target dir
mkdir -p debian/$NAME/usr
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b
