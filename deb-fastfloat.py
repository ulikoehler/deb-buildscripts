#!/usr/bin/env python3
from deblib import *
# General config
set_name("libfastfloat")
set_homepage("https://github.com/fastfloat/fast_float")
#Download it
pkgversion = "v8.0.2"
git_clone("https://github.com/fastfloat/fast_float", branch=pkgversion)
set_version(pkgversion[1:])
add_version_suffix("-deb1")
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()

#Use the existing COPYING file
copy_license("LICENSE-APACHE")

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
control_add_package(description="FastFloat library for fast parsing of floating point numbers")
control_add_package("dev",
    arch_specific=False,
    depends=[depends_main_package()],
    description="FastFloat library for fast parsing of floating point numbers (development files)")

#Build it
commandline_interface()
