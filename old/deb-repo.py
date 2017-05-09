#!/usr/bin/env python3
from deblib import *
# General config
set_name("repo")
set_homepage("https://gerrit.googlesource.com/git-repo")
#Download it
pkgversion = "1.12.37"
set_version(pkgversion)
add_version_suffix("-deb1")
git_clone("https://gerrit.googlesource.com/git-repo", branch="v" + pkgversion)
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Just copy the file
build_config["build"] = []
build_config["install"] = ["mkdir -p debian/repo/usr/bin/  && cp repo debian/repo/usr/bin/"]
write_rules()

#Create control file
intitialize_control()
control_add_package(description="Repo git repository manager")

#Build it
commandline_interface()
