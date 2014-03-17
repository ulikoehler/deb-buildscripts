#!/bin/bash
export NAME=repo
export VERSION=1.21
export DEBVERSION=${VERSION}-1
export URL=http://commondatastorage.googleapis.com/git-repo-downloads/repo
#Download it
rm -rf repo
mkdir -p repo
cd repo
wget $URL
mkdir -p debian
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
#repo package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: all" >> debian/control
echo "Depends: python2.7" >> debian/control
echo "Homepage: https://code.google.com/p/git-repo/" >> debian/control
echo "Description: Repo git repository manager" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr/bin && mv repo debian/$NAME/usr/bin" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b