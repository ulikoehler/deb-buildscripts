#!/bin/bash
export NAME=clang+llvm
export VERSION=3.2
export DEBVERSION=${VERSION}-1
wget http://llvm.org/releases/3.2/clang+llvm-3.2-x86_64-linux-ubuntu-12.04.tar.gz -O ${NAME}_-3.2.orig.tar.gz
tar xzvf ${NAME}_-3.2.orig.tar.gz
cd ${NAME}-3.2-x86_64-linux-ubuntu-12.04
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v $DEBVERSION --package $NAME ""
#Create control file
echo "Source: clang+llvm" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Provides: llvm llvm-3.2 llvm-3.2-dev llvm-dev libllvm-3.2 libllvm-3.2-dev clang clang-3.2 clang-3.2-doc" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
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