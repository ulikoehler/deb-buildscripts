#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 298D6AE3 $1
dput ppa:ulikoehler/deb-buildscripts $1