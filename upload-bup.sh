#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k FFF34765E885AB1E159B479EA4E92F1D298D6AE3 bup_*source.changes
dput ppa:ulikoehler/bup bup_*source.changes
