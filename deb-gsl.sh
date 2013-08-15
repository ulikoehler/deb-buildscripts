#!/bin/bash
export NAME=imatix-gsl
export VERSION=1.4
#Download it
git clone git://github.com/imatix/gsl.git --depth 1
cd gsl
export VERSION=$VERSION-$(git rev-list --all | wc -l)
export DEBVERSION=${VERSION}-1
rm -rf .git
cd ..
tar cJvf ${NAME}_${VERSION}.orig.tar.xz gsl
cd gsl
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
echo "Build-Depends: debhelper (>= 8)" >> debian/control
#Main package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: https://github.com/imatix/gsl" >> debian/control
echo "Description: iMatix GSL code generator" >> debian/control
#Rules files
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tcd src && make' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr/bin" >> debian/rules
echo -e "\tcp src/gsl debian/$NAME/usr/bin" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
