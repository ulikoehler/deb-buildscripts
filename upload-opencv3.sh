#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 298D6AE3 libopencv3_*source.changes
dput ppa:ulikoehler/opencv3 libopencv3_*source.changes
