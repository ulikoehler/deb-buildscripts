#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 1B69364900A773C4319949E805A0300DAE58DEBD $1
dput ppa:ulikoehler/deb-buildscripts $1