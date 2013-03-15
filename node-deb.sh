export VERSION=v0.10.0
#Compile
wget http://nodejs.org/dist/v0.10.0/node-${VERSION}.tar.gz
tar xzvf node-${VERSION}.tar.gz
mkdir usr
cd node-${VERSION}
./configure --prefix=../usr
