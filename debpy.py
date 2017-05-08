#!/usr/bin/env python3
from deblib import *
import sys
import requests
import json
from ansicolor import black, blue

def find_latest_pypi_version(pkgname, forced_version=None):
    pkginfo = requests.get("https://pypi.python.org/pypi/{}/json".format(pkgname)).json()
    pkgversion = pkginfo["info"]["version"]
    # Apply forced version
    if forced_version is not None:
        pkgversion = forced_version    
    # Find source release
    for release in pkginfo["releases"][pkgversion]:
        if release["python_version"] == "source":
            url = release["url"]
    return pkgversion, url

def build_stdeb(debsuffix, python2=True, python3=True, depends=[], build_depends=[]):
    args = ["python3" if python3 else "python",
            "setup.py",
            "--command-packages=stdeb.command",
            "sdist_dsc",
            "--suite={}".format(distribution_name())]
    args.append("--with-python2={}".format("true" if python2 else "false"))
    args.append("--with-python3={}".format("true" if python3 else "false"))
    # Add dependency arguments
    for dep in depends:
        args += ["--depends", dep]
    for dep in build_depends:
        args += ["--build-depends", dep]
    if debsuffix is not None:
        args.append("--upstream-version-suffix=-deb{}".format(debsuffix))
    print(args)
    cmd(" ".join(args))

def autobuild_python_package(nameorurl, suffix, version=None, depends=[], build_depends=[], py2=True, py3=True, remove_pyc=False):
    """
    Automatically build a python package.
    Takes either a git+http(s) or git:// URL or a package name.
    In case of a package name, the package is downloaded from PyPI
    """

    if nameorurl.startswith(("git+https://", "git+http://", "git://")) or \
       (nameorurl.startswith(("http://", "https://")) and nameorurl.endswith(".git")):
        # Git package download
        pkgname = nameorurl.rpartition("/")[2].rstrip(".git")
        print(black("Cloning {} {}...".format(pkgname,
            "(branch {})".format(version) if version else ""), bold=True))
        set_name(pkgname.lower())
        git_clone(nameorurl, branch=version)

    else: # Normal package download
        set_name(nameorurl)
        remove_old_buildtree()
        print(black("Fetching latest PyPI revision of {}".format(nameorurl), bold=True))
        pkgversion, url = find_latest_pypi_version(get_name(), forced_version=version)

        # Download and extract archive
        print(black("Downloading & extracting {}-{}".format(
            nameorurl, pkgversion), bold=True))
        wget_download(url)

    # Remove pyc (workaround) if enabled
    if remove_pyc:
        cmd("find . -name '*.pyc' -print0 | xargs -0 rm")

    # Perform build of deb package using stdeb
    print(black("Building deb package", bold=True))
    build_stdeb(suffix, py2, py3, depends=depends, build_depends=build_depends)

    # Move deb packages to current directory
    print(black("Moving build result", bold=True))
    cmd("find deb_dist -maxdepth 1 -type f -exec mv {} .. \;")

def run_pybuild_cli():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--suffix", type=int, default=1,
        help="The source version suffix. Used to upload different source versions to a PPA. Should increase by 1 for every revsion uploaded to the PPA.")
    parser.add_argument("--no-python2", action="store_false",
        help="Dont build a python2 package")
    parser.add_argument("--no-python3", action="store_false",
        help="Dont build a python2 package")
    parser.add_argument("-v", "--version",
        help="Force building a specific package version")
    parser.add_argument("-d", "--depends", nargs="*", default=[],
        help="Add specific dependencies. Note that many dependencies are auto-detected")
    parser.add_argument("-b", "--build-depends", nargs="*", default=[],
        help="Add specific dependencies. Note that many dependencies are auto-detected")
    parser.add_argument("--remove-pyc", action="store_true",
        help="Remove all pyc files from a package prior to build. Workaround for pypi packaging issues.")
    parser.add_argument("package",
        help="The pypi package to build")
    args = parser.parse_args()

    autobuild_python_package(args.package, args.suffix, args.version, args.depends,
        args.build_depends, args.no_python2, args.no_python3, remove_pyc=args.remove_pyc)

if __name__ == "__main__":
    run_pybuild_cli()
