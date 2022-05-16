#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k AE58DEBD librocksdb_*.changes
dput ppa:ulikoehler/deb-buildscripts librocksdb_*changes
