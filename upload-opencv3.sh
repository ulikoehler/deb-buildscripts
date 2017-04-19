#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 1BAA8BBC libopencv3_*source.changes
dput ppa:ulikoehler/opencv3 libopencv3_*source.changes
