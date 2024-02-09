#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 1B69364900A773C4319949E805A0300DAE58DEBD libopencv3_*source.changes
dput ppa:ulikoehler/opencv3 libopencv3_*source.changes
