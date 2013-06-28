#!/bin/bash
#NodeJS debian package builder helper script
#Builds debian packages from any NPM package, automatically determining the version etc.
#Use: deb-npm.sh <npm package name>
export NPMPKG=$1
export NAME=node-$NPMPKG #Name of debian package
#Change to dir
mkdir -p $NAME
cd $NAME
mkdir -p tmp/usr
#Change prefix and install
oldPrefix=$(npm get prefix)
npm set prefix tmp/usr
npm install -g NPMPKG
npm set prefix $oldPrefix
#Extract metainfo using NodeJS on the package.json
export PACKAGEJSON=tmp/usr/lib/node_modules/$NAME/package.json
export DESCRIPTION=$(node -e "var fs =  require('fs');process.stdout.write(JSON.parse(fs.readFileSync('${PACKAGEJSON}')).description);")
export HOMEPAGE=$(node -e "var fs =  require('fs');process.stdout.write(JSON.parse(fs.readFileSync('${PACKAGEJSON}')).homepage);")
export VERSION=$(node -e "var fs =  require('fs');process.stdout.write(JSON.parse(fs.readFileSync('${PACKAGEJSON}')).version);")
export DEBVERSION=${VERSION}-1
#Use the existing COPYING file
rm -rf debian
mkdir -p debian/${NAME}
cp tmp/usr/lib/node_modules/$NAME/LICENSE debian/copyright
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
echo "Provides: $NPMPKG" >> debian/control
echo "Depends: nodejs" >> debian/control
echo "Homepage: $HOMEPAGE" >> debian/control
echo "Description: $DESCRIPTION" >> debian/control
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