#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k AE58DEBD bup_*source.changes
dput ppa:ulikoehler/bup bup_*source.changes
