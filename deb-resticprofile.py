#!/usr/bin/env python3
from deblib import *
# General config
set_name("resticprofile")
set_homepage("https://github.com/creativeprojects/resticprofile.git")
#Download it
pkgversion = "v0.31.0"
git_clone("https://github.com/creativeprojects/resticprofile.git", branch=pkgversion)
set_version(pkgversion[1:])
add_version_suffix("-deb5")
set_debversion(5)
# Remove git
pack_source()
create_debian_dir()

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Create rules file
build_config_go()
build_config["test"] = [] # Testing fails with 0.31.0 due to IO priority stuff
write_rules()

#Create control file
intitialize_control()
control_add_package(description="Resticprofile")

#Build it
commandline_interface()
