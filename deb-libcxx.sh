#!/bin/bash
export NAME=libc++
export ARCHITECTURE=amd64
mkdir -p $NAME
cd $NAME
#Clone the directory
export URL=http://llvm.org/svn/llvm-project/libcxx/trunk
svn export $URL $NAME
export SVNVERSION=$(svn info $URL | grep Revision | cut -d' ' -f2)
export VERSION=1.0-svn$SVNVERSION
export DEBVERSION=${VERSION}-1
#Package the source
tar cJvf ${NAME}_${VERSION}.orig.tar.xz $NAME
mv ${NAME}_${VERSION}.orig.tar.xz ..
rm -rf debian
mkdir -p debian
#Use the existing COPYING file
cp $NAME/LICENSE.TXT debian/copyright
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8), cmake, clang-3.2" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: $ARCHITECTURE" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://libcxx.llvm.org/" >> debian/control
echo "Description: libc++ C++ Standard library" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: $NAME (= $DEBVERSION)" >> debian/control
echo "Homepage: http://libcxx.llvm.org/" >> debian/control
echo "Description: libc++ C++ Standard library" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tcmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INSTALL_PREFIX:PATH=`pwd`/debian/${NAME}/usr $NAME" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr" >> debian/rules
echo -e "\tmv debian/$NAME/usr/include debian/$NAME-dev/usr" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b