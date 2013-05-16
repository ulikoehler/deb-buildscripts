#!/bin/bash
export NAME=gcc-arm-eabi-toolchain
export VERSION=4.7-2013-q1
export DEBVERSION=${VERSION}-1
wget https://launchpad.net/gcc-arm-embedded/4.7/4.7-2013-q1-update/+download/gcc-arm-none-eabi-4_7-2013q1-20130313-src.tar.bz2 -O ${NAME}_${VERSION}.orig.tar.bz2
tar xjvf ${NAME}_${VERSION}.orig.tar.bz2
cd gcc-arm-none-eabi-4_7-2013q1-20130313/
#Extract and patch everything
cd src
for i in *.bz2 ; do tar xjvf $i ; done
for i in *.gz ; do tar xzvf $i ; done
cd zlib-1.2.5
patch -p1 <../zlib-1.2.5.patch
#Build the toolchain (before debuild!)
cd ../../
./build-prerequisites.sh
./build-toolchain.sh
exit
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v $DEBVERSION --package $NAME ""
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Provides: gcc-arm-none-eabi" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Description: GCC ARM EABI toolchain https://launchpad.net/gcc-arm-embedded" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo -e '\t' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/clang+llvm/usr' >> debian/rules
echo -e '\tcp -r lib include bin share debian/clang+llvm/usr' >> debian/rules
#Create some misc files
echo "8" > debian/compat
mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format
#Build the package
debuild -us -uc -b