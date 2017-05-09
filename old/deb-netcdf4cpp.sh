#!/bin/bash
export NAME=libnetcdfc++4
export VERSION=4.2.1
export DEBVERSION=${VERSION}-1
export URL=https://github.com/Unidata/netcdf-cxx4/archive/v${VERSION}.tar.gz
#Download it
if [ ! -f ${NAME}_${VERSION}.orig.tar.gz ] ; then
    wget "$URL" -O ${NAME}_${VERSION}.orig.tar.gz
fi
tar xzvf ${NAME}_${VERSION}.orig.tar.gz
cd netcdf-cxx4-${VERSION}
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
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}, libnetcdf4" >> debian/control
echo "Homepage: http://www.unidata.ucar.edu/software/netcdf/" >> debian/control
echo "Provides: libnetcdfc++4" >> debian/control
echo "Description: NetCDF C++ API" >> debian/control
#-dev package
echo "" >> debian/control
echo "Package: $NAME-dev" >> debian/control
echo "Architecture: all" >> debian/control
echo "Depends: libnetcdf4-dev" >> debian/control
echo "Homepage: http://www.unidata.ucar.edu/software/netcdf/" >> debian/control
echo "Provides: libnetcdf-dev" >> debian/control
echo "Description: NetCDF C++ API" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tCFLAGS=-march=core2 CXXFLAGS=-march=core2 ./configure --prefix=`pwd`/debian/${NAME}/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr" >> debian/rules
echo -e "\tmv debian/${NAME}/usr/include debian/$NAME-dev/usr/" >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
