#!/bin/bash
#Use the binaries from https://gist.github.com/adammw/3245130
export NAME=nodejs
export VERSION=0.10.11
export DEBVERSION=${VERSION}-1
export ARCHITECTURE=armhf
export URL=https://gist.github.com/raw/3245130/v0.10.11/node-v0.10.11-linux-arm-armv6j-vfp-hard.tar.gz
#Download it
wget "$URL" -O nodejs-bin.tar.gz
tar xzvf nodejs-bin.tar.gz
cd node-v${VERSION}-linux-arm-armv6j-vfp-hard
rm -rf debian
mkdir -p debian
#Use the existing COPYING file
mv LICENSE debian/copyright
rm ChangeLog README.md
mkdir -p debian/nodejs/usr
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
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
echo "Architecture: $ARCHITECTURE" >> debian/control
echo "Depends: \${shlibs:Depends}, \${misc:Depends}" >> debian/control
echo "Homepage: http://nodejs.org/" >> debian/control
echo "Description: NodeJS" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmv bin include lib share debian/nodejs/usr/' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\t' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b