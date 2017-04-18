#!/usr/bin/env python3
from deblib import *
# General config
set_name("libjemalloc")
remove_old_buildtree()
set_homepage("https://github.com/jemalloc/jemalloc")
#Download it
pkgversion = "4.5.0"
set_version("4.5.0-deb2")
git_clone("https://github.com/jemalloc/jemalloc.git", branch=pkgversion)
set_debversion(2)
# Remove git
pack_source()
create_debian_dir()

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Create rules file
build_config_autotools(targets=["all", "dist"])
install_usr_dir_to_package("usr/include", "dev")
install_usr_dir_to_package("usr/share", "doc")
write_rules()

build_depends += ["xsltproc", "docbook-xsl"]

#Create control file
intitialize_control()
control_add_package(description="JeMalloc memory allocator")
control_add_package("dev",
    arch_specific=False,
    description="JeMalloc memory allocator (development files)")
control_add_package("doc",
    arch_specific=False,
    description="JeMalloc memory allocator (documentation)")

#Build it
commandline_interface()
