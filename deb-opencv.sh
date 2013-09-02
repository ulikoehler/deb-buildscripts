#!/bin/bash
echo "THIS IS NOT FINISHED YET!"
exit
export NAME=libopencv 
export VERSION=2.4.6.1
export DEBVERSION=${VERSION}-1
export ARCHITECTURE=all
export URL="http://downloads.sourceforge.net/project/opencvlibrary/opencv-unix/2.4.6.1/opencv-2.4.6.1.tar.gz?r=http%3A%2F%2Fopencv.org%2Fdownloads.html&ts=1378133315&use_mirror=switch"
#Download it
wget "$URL" -O ${NAME}_${VERSION}.orig.tar.bz2
tar xjvf ${NAME}_${VERSION}.orig.tar.bz2
cd OpenCV-2.4.6.1
rm -rf debian
mkdir -p debian
#Use the existing COPYING file
cp LICENSE debian/copyright
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: $ARCHITECTURE" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://opencv.willowgarage.com/" >> debian/control
echo "Description: OpenCV" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libopencv (= $VERSION)" >> debian/control
echo "Homepage: http://opencv.willowgarage.com/" >> debian/control
echo "Description: OpenCV" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t./configure --prefix=`pwd`/debian/${NAME}/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p deian/${NAME}-dev/user" >> debian/rules
echo -e '\tmake install' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc