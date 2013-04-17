#!/bin/bash
if [ ! -d "boost_1_53_0" ]; then
    wget "http://downloads.sourceforge.net/project/boost/boost/1.53.0/boost_1_53_0.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fboost%2Ffiles%2Fboost%2F1.53.0%2F&ts=1364690822&use_mirror=surfnet" -O boost-all_1.53.0.orig.tar.bz2
    tar xjvf boost-all_1.53.0.orig.tar.bz2
fi
    cd boost_1_53_0
#Build DEB
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v 1.53.0-1 --package boost-all ""
#Create copyright file
touch debian
#Create control file
echo <<EOF > debian/control
Source: boost-all
Maintainer: None <none@example.com>
Section: misc
Priority: optional
Standards-Version: 3.9.2
Build-Depends: debhelper (>= 8)

Package: boost-all
Architecture: amd64
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Boost library, version 1.53.0 (shared libraries)

Package: boost-all-doc
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}, boost-all ($VERSION)
Description: Boost library, version 1.53.0 (documentation)

Package: boost-all-dev
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Boost library, version 1.53.0 (development files)

Package: bjam
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Boost Build v2 bjam executable
EOF
#Create rules file
echo <<EOF > debian/rules
#!/usr/bin/make -f
%:
dh $@
override_dh_auto_clean:
\t
override_dh_auto_configure:
\t./bootstrap.sh
override_dh_auto_build:
\t./b2 --prefix=`pwd`/debian/boost-all/usr/
\t./b2 tools/build/v2
override_dh_auto_test:
\t
override_dh_auto_install:
\tmkdir -p debian/boost-all/usr debian/boost-all-dev/usr debian/boost-all-doc/usr debian/bjam/usr/bin
\t./b2 --prefix=`pwd`/debian/boost-all/usr/ install
\tmv debian/boost-all/usr/include debian/boost-all-dev
\tmv debian/boost-all/usr/doc debian/boost-all-doc
EOF
#Create some misc files
echo "8" > debian/compat
mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format
#Build the package
debuild -us -uc