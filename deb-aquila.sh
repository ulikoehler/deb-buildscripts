#!/bin/bash
export NAME=libaquila
#Download it
git clone https://github.com/zsiciarz/aquila.git
export VERSION=3.0.0-git$(cd aquila && git rev-list --all | wc -l)
export DEBVERSION=${VERSION}-1
echo $VERSION
# Remove git
(cd aquila && rm -rf .git && cd ..)
# Pack
tar cJvf ${NAME}_${VERSION}.orig.tar.xz aquila
cd aquila
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
echo "Architecture: amd64" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: https://github.com/zsiciarz/aquila" >> debian/control
echo "Description: Aquila DSP library" >> debian/control
#-dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: all" >> debian/control
echo "Depends: $NAME" >> debian/control
echo "Homepage: https://github.com/zsiciarz/aquila" >> debian/control
echo "Description: Aquila DSP library" >> debian/control
#Rules files
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tcmake . -DCMAKE_INSTALL_PREFIX=debian/$NAME/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake all aquila_test' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr" >> debian/rules
echo -e "\tmake install PREFIX=debian/$NAME/usr" >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr/ && mv debian/$NAME/usr/include debian/$NAME-dev/usr/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
