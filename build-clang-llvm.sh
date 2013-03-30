#!/bin/bash
wget http://llvm.org/releases/3.2/clang+llvm-3.2-x86_64-linux-ubuntu-12.04.tar.gz
mv clang+llvm-3.2-x86_64-linux-ubuntu-12.04.tar.gz clang+llvm_-3.2.orig.tar.gz
tar xzvf clang+llvm_-3.2.orig.tar.gz
cd clang+llvm-3.2-x86_64-linux-ubuntu-12.04
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v 3.3-1 --package clang+llvm ""
#Create copyright file
touch debian
#Create control file
echo "Source: clang+llvm" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: clang+llvm" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Provides: llvm llvm-3.3 llvm-3.3-dev llvm-dev libllvm-3.3 libllvm-3.3-dev clang clang-3.3 clang-3.3-doc" >> debian/control
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