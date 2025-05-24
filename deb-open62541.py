#!/usr/bin/env python3
from deblib import *
# General config
set_name("libopen62541")
set_homepage("https://open62541.org/")
#Download it
pkgversion = "v1.4.12"
git_clone("https://github.com/open62541/open62541.git", branch=pkgversion)
set_version(pkgversion[1:])
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
build_config_cmake(cmake_opts=[])
install_usr_dir_to_package("usr/include", "dev")
write_rules()

#Create control file
intitialize_control()
control_add_package(description="Open62541 OPC-UA C/C++ library")
control_add_package("dev",
    arch_specific=False,
    depends=[depends_main_package()],
    description="Open62541 OPC-UA C/C++ library (development files)")

#Build it
commandline_interface()
