#!/bin/bash
export NAME=seqan
export VERSION=1.4.1
export DEBVERSION=${VERSION}-1
export URL=http://packages.seqan.de/seqan-library/seqan-library-${VERSION}.tar.bz2
#Download it
if [ ! -f seqan-library-${VERSION}.tar.bz2 ] ; then
    wget "$URL"
fi
tar xjvf seqan-library-1.4.1.tar.bz2
cd seqan-library-${VERSION}
rm -rf debian
mkdir -p debian
#Use the existing license file
cp share/doc/seqan/LICENSE debian/copyright
#Rename the doc package

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
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: all" >> debian/control
echo "Recommends: $NAME-doc" >> debian/control
echo "Homepage: https://seqan.de" >> debian/control
echo "Description: SeqAn Sequence analysis library - header-only include files" >> debian/control
#-doc package
echo "" >> debian/control
echo "Package: $NAME-doc" >> debian/control
echo "Architecture: all" >> debian/control
echo "Homepage: https://seqan.de" >> debian/control
echo "Description: SeqAn Sequence analysis library - documentation" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr/ && mv include debian/$NAME-dev/usr/" >> debian/rules
echo -e "\tmkdir -p debian/$NAME-doc/usr/ && mv share debian/$NAME-doc/usr/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b