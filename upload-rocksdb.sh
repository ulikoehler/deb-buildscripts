#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 5D4FAE38 librocksdb_*.changes
dput ppa:ulikoehler/deb-buildscripts librocksdb_*changes
