#!/usr/bin/env python3
from deblib import *
# General config
set_name("libargparse")
set_homepage("https://github.com/p-ranav/argparse")
#Download it
pkgversion = "3.2"
git_clone("https://github.com/p-ranav/argparse.git", branch=f"v{pkgversion}")
set_version(pkgversion)
add_version_suffix("-deb1")
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Create rules file
build_config_cmake()
install_file("include/argparse", "usr/include")
install_usr_dir_to_package("usr/include", "dev")
build_config["test"] = ["./test/tests"]
write_rules()

build_depends += ["python3-dev"]

#Create control file
intitialize_control()
control_add_package("dev",
    arch_specific=False,
    depends=["build-essential"],
    description="libargparse - Command-line argument parser for C++ (header-only library)")

#Build it
commandline_interface()
