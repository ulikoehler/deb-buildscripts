#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 5D4FAE38 $1
dput ppa:ulikoehler/opensfm $1
