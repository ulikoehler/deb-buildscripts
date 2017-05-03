#!/usr/bin/env python3
from deblib import *
import sys
import requests
import json
from ansicolor import black, blue

def find_latest_pypi_version(pkgname):
    pkginfo = requests.get("https://pypi.python.org/pypi/{}/json".format(pkgname)).json()
    pkgversion = pkginfo["info"]["version"]
    # Find source release
    for release in pkginfo["releases"][pkgversion]:
        if release["python_version"] == "source":
            url = release["url"]
    return pkgversion, url

def build_stdeb(debsuffix, python2=True, python3=True):
    args = ["python3",
            "setup.py",
            "--command-packages=stdeb.command",
            "sdist_dsc",
            "--suite={}".format(distribution_name()),
            "--with-python3=True"]
    if python2:
        args.append("--with-python2=true")
    if python3:
        args.append("--with-python3=true")
    if debsuffix is not None:
        args.append("--upstream-version-suffix=-deb{}".format(debsuffix))
    cmd(" ".join(args))

# Run commandline interface
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-s", "--suffix", type=int, default=1
    help="The source version suffix. Used to upload different source versions to a PPA. Should increase by 1 for every revsion uploaded to the PPA.")
parser.add_argument("--no-python2", action="store_false",
    help="Dont build a python2 package")
parser.add_argument("--no-python3", action="store_false",
    help="Dont build a python2 package")
parser.add_argument("package",
    help="The pypi package to build")
args = parser.parse_args()

set_name(args.package)
remove_old_buildtree()
print(black("Fetching latest PyPI revision of {}".format(args.package, bold=True)))
pkgversion, url = find_latest_pypi_version(get_name())

# Download and extract archive
print(black("Downloading & extracting {}-{}".format(
    args.package, pkgversion, bold=True)))
wget_download(url)

# Perform build of deb package using stdeb
print(black("Building deb package", bold=True))
build_stdeb(args.suffix, args.no_python2, args.no_python3)

# Move deb packages to current directory
print(black("Moving build result", bold=True))
cmd("find deb_dist -maxdepth 1 -type f -exec mv {} .. \;")
