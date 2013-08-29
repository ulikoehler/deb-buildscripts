#!/bin/bash
export NAME=opendetex
export VERSION=2.8.1
export DEBVERSION=${VERSION}-2
export URL=https://opendetex.googlecode.com/files/opendetex-${VERSION}.tar.bz2
#Download it
wget "$URL" -O ${NAME}_${VERSION}.orig.tar.bz2
tar xjvf ${NAME}_${VERSION}.orig.tar.bz2
cd opendetex
rm -rf debian
mkdir -p debian
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create copyright file
cp COPYRIGHT debian/copyright
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8), flex" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: all" >> debian/control
echo "Provides: detex" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: https://code.google.com/p/opendetex/" >> debian/control
echo "Description: OpenDetex TeX/LaTeX plaintext extractor" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr/bin" >> debian/rules
echo -e "\tcp detex delatex debian/$NAME/usr/bin" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc