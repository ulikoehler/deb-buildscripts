#!/usr/bin/env python3
from deblib import *
# General config
set_name("opensfm")
set_homepage("https://github.com/mapillary/OpenSfM")
#Download it
git_clone("https://github.com/mapillary/OpenSfM.git")
set_version("0.1", gitcount=True)
add_version_suffix("-deb14")
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()

#Use the existing COPYING file
copy_license()

build_depends += [
    "libceres1-dev",
    "python-exifread",
    "python-pyproj",
    "python-networkx",
    "libboost-python-dev",
    "python-gpxpy",
    "cmake",
    "pkg-config",
    "libeigen3-dev",
    "libgflags-dev",
    "libopencv-dev",
    "libgoogle-glog-dev",
    "libsuitesparse-dev",
    "python-xmltodict",
    "libopengv-dev",
    "libopengv-python",
    "python-scipy"]

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Create rules file
build_config_python(python="python2")
build_config["install"].append(
    "mv debian/opensfm/usr/lib/python2.7/site-packages debian/opensfm/usr/lib/python2.7/dist-packages"
)
write_rules()

#Create control file
intitialize_control()
control_add_package(
    depends=[
        "libceres1",
        "libopengv-python",
        "python-exifread",
        "python-networkx",
        "python-gpxpy",
        "python-pyproj",
        "python-opencv",
        "python-scipy",
	"python-xmltodict"
    ],
    description="OpenSfM structure from motion implementation")

#Build it
commandline_interface()
