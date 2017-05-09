#!/bin/bash
wget ftp://opensource.dyc.edu/pub/sthttpd/sthttpd-2.26.3.tar.gz
mv sthttpd-2.26.3.tar.gz sthttpd_2.26.3.orig.tar.gz
tar xzvf sthttpd_2.26.3.orig.tar.gz
cd sthttpd-2.26.3
rm -rf debian
mkdir -p debian
#Use the LICENSE file from nodejs as copying file
touch debian/copying
#Create the changelog (no messages needed)
dch --create -v 2.26.3-1 --package sthttpd ""
#Create copyright file
echo "** Copyright 1995,1998,1999,2000,2001 by Jef Poskanzer <jef@mail.acme.com>." > debian/copyright
echo "** All rights reserved." >> debian/copyright
echo "**" >> debian/copyright
echo "** Redistribution and use in source and binary forms, with or without" >> debian/copyright
echo "** modification, are permitted provided that the following conditions" >> debian/copyright
echo "** are met:" >> debian/copyright
echo "** 1. Redistributions of source code must retain the above copyright" >> debian/copyright
echo "**    notice, this list of conditions and the following disclaimer." >> debian/copyright
echo "** 2. Redistributions in binary form must reproduce the above copyright" >> debian/copyright
echo "**    notice, this list of conditions and the following disclaimer in the" >> debian/copyright
echo "**    documentation and/or other materials provided with the distribution." >> debian/copyright
echo "**" >> debian/copyright
echo "** THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND" >> debian/copyright
echo "** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE" >> debian/copyright
echo "** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE" >> debian/copyright
echo "** ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE" >> debian/copyright
echo "** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL" >> debian/copyright
echo "** DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS" >> debian/copyright
echo "** OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)" >> debian/copyright
echo "** HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT" >> debian/copyright
echo "** LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY" >> debian/copyright
echo "** OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF" >> debian/copyright
echo "** SUCH DAMAGE." >> debian/copyright
#Create control file
echo "Source: sthttpd" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8)" >> debian/control
echo "" >> debian/control
echo "Package: sthttpd" >> debian/control
echo "Version: 2.25b-1" >> debian/control
echo "Architecture: amd64" >> debian/control
echo "Depends: ${shlibs:Depends}, ${misc:Depends}" >> debian/control
echo "Homepage: http://opensource.dyc.edu/sthttpd" >> debian/control
echo "Description: sthttpd thttpd replacement" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e '\t./configure' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmkdir -p debian/sthttpd/usr/bin' >> debian/rules
echo -e '\tcp src/thttpd debian/sthttpd/usr/bin' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
debuild -us -uc