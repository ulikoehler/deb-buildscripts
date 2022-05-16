#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k AE58DEBD $1
dput ppa:ulikoehler/deb-buildscripts $1