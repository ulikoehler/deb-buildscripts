#sudo apt-get install devscripts
export VERSION=0.10.0
#Compile
wget http://nodejs.org/dist/v0.10.0/node-v${VERSION}.tar.gz
mv node-v${VERSION}.tar.gz nodejs_${VERSION}-wotspot.orig.tar.gz
tar xzvf nodejs_${VERSION}-wotspot.orig.tar.gz
cd nodejs-v${VERSION}
#Create stuff
mkdir debian
cp ../LICENSE debian/copying
dch --create -v ${VERSION}-wspot --package nodejs ""
echo "8" > debian/compat
#Create control file
echo "Package: nodejs" > debian/control
echo "Version: ${VERSION}-wspot" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Maintainer: btronik <ukoehler@btronik.de>" >> debian/control
echo "Depends: libc6 (>= 2.6), libssl1.0.0 (>= 1.0.1), libstdc++6 (>= 4.1.1), zlib1g (>= 1:1.1.4)" >> debian/control
echo "Section: web" >> debian/control
echo "Priority: extra" >> debian/control
echo "Homepage: http://nodejs.org/" >> debian/control
echo "Description: Node.js WOTSPOT distribution" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo '	dh $@' >> debian/rules
#
mkdir -p debian/source
echo "3.0 (quilt)" > debian/source/format