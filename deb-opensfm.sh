#!/bin/sh
./debpy.py https://github.com/mapillary/OpenSfM.git --no-python3 -b libopencv-dev -b libgoogle-glog-dev -b libeigen3-dev -d python-gpxpy -d python-exifread -b libceres1-dev -d libceres1 -b libboost-python-dev -d python-yaml -d python-networkx -d python-opencv -d python-pyproj -b cmake -s 4
