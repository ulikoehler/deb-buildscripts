#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k AE58DEBD libopencv3_*source.changes
dput ppa:ulikoehler/opencv3 libopencv3_*source.changes
