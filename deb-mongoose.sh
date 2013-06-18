#!/bin/bash
wget https://mongoose.googlecode.com/files/mongoose-3.7.tgz
mv mongoose-3.7.tgz mongoose_3.7.orig.tar.gz
tar xzvf mongoose_3.7.orig.tar.gz
cd mongoose
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v 3.7-1 --package mongoose ""
#Create copyright file
cp LICENSE debian/copyright
#Create control file
echo "Source: mongoose" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: mongoose" >> debian/control
echo "Architecture: $(dpkg-architecture -qDEB_HOST_ARCH)" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: https://code.google.com/p/mongoose/" >> debian/control
echo "Description: Mongoose minimal webserver" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake --always-make linux' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/mongoose/usr/bin' >> debian/rules
echo -e '\tcp mongoose debian/mongoose/usr/bin' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc