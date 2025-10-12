#!/usr/bin/env python3
from deblib import *
# General config
set_name("libsoem")
set_homepage("https://github.com/OpenEtherCATsociety/SOEM.git")
#Download it
pkgversion = "v2.0.0"
git_clone("https://github.com/OpenEtherCATsociety/SOEM.git", branch=pkgversion)
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
build_config_cmake(cmake_opts=[
    "-DCMAKE_BUILD_TYPE=Release",
])
install_usr_dir_to_package("usr/include", "dev")
write_rules()

#Create control file
intitialize_control()
control_add_package(description="SOEM EtherCAT master", depends=[],)
control_add_package("dev",
    arch_specific=False,
    depends=[depends_main_package()],
    description="SOEM EtherCAT master development files")

#Build it
commandline_interface()
