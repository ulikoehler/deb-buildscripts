#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 298D6AE3 librocksdb_*.changes
dput ppa:ulikoehler/deb-buildscripts librocksdb_*changes
