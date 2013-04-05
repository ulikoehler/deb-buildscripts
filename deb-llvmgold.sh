#!/bin/bash
export NAME=llvm-gold-plugin
export ARCHITECTURE=amd64
export VERSION=3.2
export DEBVERSION=${VERSION}-1
#Clone the directory
export URL=http://llvm.org/releases/${VERSION}/llvm-${VERSION}.src.tar.gz
wget $URL
#Package the source
tar xzvf llvm-${VERSION}.src.tar.gz
cd llvm-3.2.src
rm -rf debian
mkdir -p debian
#Use the existing COPYING file
cp LICENSE.TXT debian/copyright
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8), binutils-dev, binutils-gold, clang" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: $ARCHITECTURE" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://llvm.org/" >> debian/control
echo "Description: LLVM GOLD linker plugin" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tCXX=g++ ./configure --with-binutils-include=/usr/include" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8 ENABLE_OPTIMIZED=1' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr/lib" >> debian/rules
echo -e "\tcp ./Release+Asserts/lib/LLVMgold.so debian/$NAME/usr/lib" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b