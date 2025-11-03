#!/usr/bin/env python3
from deblib import *
# General config
set_name("librtipc")
set_homepage("https://gitlab.com/etherlab.org/rtipc")
#Download it
pkgversion = "1.0.3"
git_clone("https://gitlab.com/etherlab.org/rtipc.git", branch=pkgversion)
set_version(pkgversion)
add_version_suffix("-deb3")
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Build dependencies
build_depends += [
    "cmake",
    "libyaml-dev",
    "libmhash-dev"
]

# Create rules file
build_config_cmake(cmake_opts=[
    "-DCMAKE_BUILD_TYPE=Release",
])
install_usr_dir_to_package("usr/include", "dev")
write_rules()

#Create control file
intitialize_control()
control_add_package(description="Real-Time Inter-Process-Communication (RTIPC)", depends=[
    "libyaml-0-2",
    "libmhash2"
],)
control_add_package("dev",
    arch_specific=False,
    depends=[
        depends_main_package(),
        "libyaml-dev",
        "libmhash-dev"
    ],
    description="RTIPC development files",)

#Build it
commandline_interface()
