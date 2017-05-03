#!/usr/bin/env python3
from deblib import *
import sys
import requests
import json

pkgname = "exifread"

def find_latest_pypi_version(pkgname):
    pkginfo = requests.get("https://pypi.python.org/pypi/{}/json".format(pkgname)).json()
    pkgversion = pkginfo["info"]["version"]
    # Find source release
    for release in pkginfo["releases"][pkgversion]:
        if release["python_version"] == "source":
            url = release["url"]
    return pkgversion, url

args = ["python3",
        "setup.py",
        "--command-packages=stdeb.command",
        "sdist_dsc",
        "--suite={}".format(distribution_name()),
        "--with-python3=True",
        "--upstream-version-suffix=-deb{}".form]

# General config
set_name("python-" - exifread)
set_homepage("http://ceres-solver.org/")
#Download it
pkgversion = "1.12.0"
git_clone("https://ceres-solver.googlesource.com/ceres-solver", branch=pkgversion)
set_version(pkgversion + "-deb3")
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Create rules file
build_config_cmake(cmake_opts=[
    "-DCMAKE_C_FLAGS=-fPIC",
    "-DCMAKE_CXX_FLAGS=-fPIC",
    "-DBUILD_EXAMPLES=OFF",
    "-DBUILD_SHARED_LIBS=ON"])
install_usr_dir_to_package("usr/include", "dev")
write_rules()

#Create control file
intitialize_control()
control_add_package(description="Ceres solver")
control_add_package("dev",
    arch_specific=False,
    depends=[depends_main_package()],
    description="Ceres solver (development files)")

#Build it
commandline_interface()
