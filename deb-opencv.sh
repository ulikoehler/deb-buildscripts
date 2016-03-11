#!/bin/bash
export NAME=libopencv3
export VERSION=3.1.0
export DEBVERSION=${VERSION}-1
export ARCHITECTURE=all
export URL="https://github.com/Itseez/opencv/archive/3.1.0.zip"
# Download contrib
git clone https://github.com/Itseez/opencv_contrib.git
cd opencv_contrib && git co 3.1.0 && cd ..
#Download it
wget "$URL" -c -O ${NAME}_${VERSION}.zip
# Create a fresh unzip and create .orig.tar.bz2
rm -rf opencv-${VERSION}
unzip -n ${NAME}_${VERSION}.zip
rm ${NAME}_${VERSION}.orig.tar.bz2
tar cjvf ${NAME}_${VERSION}.orig.tar.bz2 opencv-${VERSION}
cd opencv-${VERSION}
rm -rf debian && mkdir -p debian
mkdir build
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
echo "Build-Depends: debhelper (>= 8), libv4l-dev, libavresample-dev" >> debian/control
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
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libopencv3 (= $VERSION)" >> debian/control
echo "Homepage: http://opencv.willowgarage.com/" >> debian/control
echo "Description: OpenCV" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tcd build && cmake .. -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=../debian/$NAME/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tcd build && make -j6' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tcd build && make install' >> debian/rules
echo -e "\tcd build && mkdir -p ../debian/${NAME}-dev/usr" >> debian/rules
echo -e "\tcd build && mv ../debian/${NAME}/usr/include ../debian/${NAME}-dev/usr" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc