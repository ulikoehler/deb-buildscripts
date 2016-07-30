#!/bin/bash
export NAME=libopencv3
export VERSION=3.1.0
export DEBVERSION=${VERSION}-1
export ARCHITECTURE=any

# Delete old build directory
rm -rf opencv_build
# Download main & contrib & unpack
# Download OpenCV
rm -rf opencv
if [ ! -f opencv-$VERSION.zip ]; then
    wget https://github.com/Itseez/opencv/archive/$VERSION.zip -O opencv-$VERSION.zip
fi
unzip opencv-$VERSION.zip
mv opencv-$VERSION opencv

# Download OpenCV contrib
rm -rf opencv_contrib
if [ ! -f opencv_contrib-$VERSION.zip ]; then
    wget https://github.com/Itseez/opencv_contrib/archive/$VERSION.zip -O opencv_contrib-$VERSION.zip
fi
unzip opencv_contrib-$VERSION.zip
mv opencv_contrib-$VERSION opencv_contrib

mkdir opencv_build && cd opencv_build

# Fix #6016, see https://github.com/opencv/opencv/issues/6016
sed -i '3s/^/find_package(HDF5)\ninclude_directories(${HDF5_INCLUDE_DIRS})/' ../opencv/modules/python/common.cmake

# Configure build

export PKGS_BUILD_TOOLS="build-essential, cmake"
export PKGS_VIZ="libgtkglext1-dev, libvtk6-dev"
export PKG_IMG="zlib1g-dev, libjpeg-dev, libwebp-dev, libpng-dev, libtiff5-dev, libjasper-dev, libopenexr-dev, libgdal-dev"
export PKG_VIDEO="libdc1394-22-dev, libavcodec-dev, libavformat-dev, libswscale-dev, libtheora-dev, libvorbis-dev, libxvidcore-dev, libx264-dev, yasm, libopencore-amrnb-dev, libopencore-amrwb-dev, libv4l-dev, libxine2-dev"
export PKG_MATH="libtbb-dev, libeigen3-dev"
export PKG_PYTHON="python-dev, python-tk, python-numpy, python3-dev, python3-tk, python3-numpy"
export PKG_UTIL="unzip, wget, doxygen"
export PKG_OCR="libtesseract-dev"
export ALL_PKGS="$PKGS_BUILD_TOOLS, $PKGS_VIZ, $PKG_IMG, $PKG_VIDEO, $PKG_MATH, $PKG_PYTHON, $PKG_UTIL, $PKG_OCR"

rm -rf debian && mkdir -p debian/$NAME/usr
cmake -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_PRECOMPILED_HEADERS=OFF -DCMAKE_INSTALL_PREFIX=debian/$NAME/usr -DWITH_CUDA=OFF -DWITH_OPENGL=ON -DWITH_TBB=ON -DWITH_GDAL=ON -DBUILD_EXAMPLES=OFF -D INSTALL_PYTHON_EXAMPLES=ON -D INSTALL_C_EXAMPLES=OFF -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules ../opencv/

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
echo "Build-Depends: debhelper (>= 8), $ALL_PKGS" >> debian/control

#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: $ARCHITECTURE" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://opencv.willowgarage.com/" >> debian/control
echo "Description: OpenCV" >> debian/control

#Dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: $ARCHITECTURE" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, $NAME (= $DEBVERSION)" >> debian/control
echo "Homepage: http://opencv.willowgarage.com/" >> debian/control
echo "Description: OpenCV" >> debian/control

#Python2 package
echo "" >> debian/control
echo "Package: $NAME-python2" >> debian/control
echo "Architecture: $ARCHITECTURE" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, $NAME (= $DEBVERSION), python, python-support (>= 0.90)" >> debian/control
echo "Homepage: http://opencv.willowgarage.com/" >> debian/control
echo "Description: OpenCV" >> debian/control

#Python3 package
echo "" >> debian/control
echo "Package: $NAME-python3" >> debian/control
echo "Architecture: $ARCHITECTURE" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, $NAME (= $DEBVERSION), python3, python-support (>= 0.90)" >> debian/control
echo "Homepage: http://opencv.willowgarage.com/" >> debian/control
echo "Description: OpenCV" >> debian/control

#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_test:' >> debian/rules # Do not run OpenCV tests here because they take super-long.
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmkdir -p debian/${NAME}-dev/usr debian/${NAME}-python3/usr/lib/ debian/${NAME}-python/usr/lib/" >> debian/rules
echo -e "\tmv debian/${NAME}/usr/include debian/${NAME}-dev/usr" >> debian/rules
# Python2/3-specific stuff
echo -e "\tmv debian/${NAME}/usr/lib/python2*  debian/${NAME}-python3/usr/lib/" >> debian/rules
echo -e "\tmv debian/${NAME}/usr/lib/python3* debian/${NAME}-python3/usr/lib/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -i -us -uc -b