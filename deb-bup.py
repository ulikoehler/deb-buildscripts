#!/usr/bin/env python3
from deblib import *
# General config
set_name("bup")
set_homepage("https://github.com/bup/bup")
#Download it
pkgversion = "0.33.2"
set_version(pkgversion)
add_version_suffix("-deb2")
git_clone("https://github.com/bup/bup.git", branch=pkgversion)
set_debversion(1)
# Remove git
pack_source(keep_git=True) # bup needs git to know its version
create_debian_dir()

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Create rules file
build_config_autotools(targets=["all"])
# Special rules for bup
build_config["configure"] = ["./configure"]
build_config["install"] = ["make install PREFIX=debian/{}/usr".format(get_name())]
build_config["clean"] = []
build_config["test"] = []
write_rules()

build_depends += ["python3-dev", "git", "libacl1-dev", "libreadline-dev", "pandoc"]

#Create control file
intitialize_control()
control_add_package(description="bup incremental backup tool", depends=["python-is-python2 | python-is-python3"])

#Build it
commandline_interface()
