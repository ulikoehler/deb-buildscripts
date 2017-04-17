#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 1BAA8BBC $1
dput ppa:ulikoehler/deb-buildscripts $1