#sudo apt-get install devscripts
export VERSION=0.10.0
#Compile
wget http://nodejs.org/dist/v0.10.0/node-v${VERSION}.tar.gz
tar xzvf node-v${VERSION}.tar.gz
mkdir usr
cd node-${VERSION}
./configure --prefix=../usr
make -j8
#
cd ../usr
mkdir debian
dch --create -v ${VERSION}-wspot --package nodejs