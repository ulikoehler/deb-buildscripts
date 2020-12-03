#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 5D4FAE38 bup_*source.changes
dput ppa:ulikoehler/bup bup_*source.changes
