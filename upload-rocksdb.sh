#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 1BAA8BBC librocksdb_*.changes
dput ppa:ulikoehler/deb-buildscripts librocksdb_*changes
