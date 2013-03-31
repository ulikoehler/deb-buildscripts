#!/bin/bash
wget "http://downloads.sourceforge.net/project/boost/boost/1.53.0/boost_1_53_0.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fboost%2Ffiles%2Fboost%2F1.53.0%2F&ts=1364690822&use_mirror=surfnet" -O boost-all_1.53.0.orig.tar.bz2
tar xjvf boost-all_1.53.0.orig.tar.bz2
cd boost_1_53_0
#Build DEB
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v 1.53.0-1 --package boost-all ""
#Create copyright file
touch debian
#Create control file
echo "Source: boost-all" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: boost-all" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Description: Boost library, version 1.53.0, including all development files and documentation" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t./bootstrap.sh' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\t./b2 --prefix=`pwd`/debian/boost-all/usr/' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/boost-all/usr' >> debian/rules
echo -e '\t./b2 --prefix=`pwd`/debian/boost-all/usr/ install' >> debian/rules
#Create some misc files
echo "8" > debian/compat
mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format
#Build the package
debuild -us -uc