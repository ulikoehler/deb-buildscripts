#!/bin/bash
export NAME=node-forever
export VERSION=0.10.8
export DEBVERSION=${VERSION}-1
#Change to dir
mkdir -p forever
cd forever
mkdir -p tmp/usr
#Change prefix and install
oldPrefix=$(npm get prefix)
npm set prefix tmp/usr
npm install -g forever
npm set prefix $oldPrefix
#Use the existing COPYING file
rm -rf debian
mkdir -p debian/${NAME}
cp tmp/usr/lib/node_modules/forever/LICENSE debian/copyright
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
#-dev package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Provides: forever" >> debian/control
echo "Depends: nodejs" >> debian/control
echo "Homepage: https://github.com/nodejitsu/forever" >> debian/control
echo "Description: Forever NodeJS Daemon" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmv tmp/usr debian/${NAME}" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b