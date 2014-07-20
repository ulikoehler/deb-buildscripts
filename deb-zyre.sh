#!/bin/bash
export NAME=libzyre
export VERSION=1.0.0
export DEBVERSION=${VERSION}-2
#Download it
git clone https://github.com/zeromq/zyre.git
cd zyre
git checkout v${VERSION}
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
echo "Build-Depends: debhelper (>= 8), libczmq (>= 2.0), libzmq4-dev, libczmq-dev" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Provides: libzyre1" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libzmq4 (>= 4.0)," >> debian/control
echo "Homepage: https://github.com/zeromq/zyre" >> debian/control
echo "Description: ZyRe ZMQ autodiscovery library" >> debian/control
#-dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: all" >> debian/control
echo "Provides: libczmq-dev" >> debian/control
echo "Replaces: libczmq-dev" >> debian/control
echo "Conflicts: libczmq-dev" >> debian/control
echo "Depends: libzmq4-dev (>= 3.0), libczmq-dev (>= 2.0), libzyre (= $DEBVERSION) " >> debian/control
echo "Homepage: https://github.com/zeromq/zyre" >> debian/control
echo "Description:  ZyRe ZMQ autodiscovery library" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tcmake . -DCMAKE_INSTALL_PREFIX:PATH=`pwd`/debian/${NAME}/usr -DCMAKE_BUILD_TYPE=Release" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr debian/$NAME-dev/usr" >> debian/rules
echo -e "\tmv debian/$NAME/usr/include debian/$NAME-dev/usr/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc -b

