#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 5D4FAE38 libopencv3_*source.changes
dput ppa:ulikoehler/opencv3 libopencv3_*source.changes
