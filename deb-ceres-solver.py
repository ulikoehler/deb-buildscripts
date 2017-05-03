#!/usr/bin/env python3
from deblib import *
# General config
set_name("ceres-solver")
set_homepage("http://ceres-solver.org/")
#Download it
pkgversion = "1.12.0"
git_clone("https://ceres-solver.googlesource.com/ceres-solver", branch=pkgversion)
set_version(pkgversion + "-deb1")
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()

build_depends.append("libgflags-dev")
build_depends.append("libeigen3-dev")
build_depends.append("libgoogle-glog-dev")

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Create rules file
build_config_cmake(cmake_opts=[
    "-DCMAKE_C_FLAGS=-fPIC",
    "-DCMAKE_CXX_FLAGS=-fPIC",
    "-DBUILD_EXAMPLES=OFF"])
install_usr_dir_to_package("usr/include", "dev")
write_rules()

#Create control file
intitialize_control()
control_add_package(description="Ceres solver")
control_add_package("dev",
    arch_specific=False,
    description="Ceres solver (development files)")

#Build it
commandline_interface()
