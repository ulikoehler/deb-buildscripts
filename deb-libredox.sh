#!/usr/bin/env python3
from deblib import *
# General config
set_name("libredox")
set_homepage("https://github.com/hmartiro/redox")
#Download it
pkgversion = "1.0"
git_clone("https://github.com/hmartiro/redox", branch="master")
set_version(pkgversion)
add_version_suffix("-deb1")
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()

build_depends.append("libhiredis-dev")
build_depends.append("libev-dev")

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Create rules file
build_config_cmake(cmake_opts=[])
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
