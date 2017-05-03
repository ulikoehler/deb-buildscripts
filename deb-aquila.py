#!/usr/bin/env python3
from deblib import *
# General config
set_name("libaquila")
set_homepage("https://github.com/zsiciarz/aquila")
#Download it
git_clone("https://github.com/zsiciarz/aquila.git")
set_version("3.0.0", gitcount=True)
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
test_config("make aquila_test")
install_file("lib/libOoura_fft.a", "usr/lib")
install_usr_dir_to_package("usr/include", "dev")
write_rules()

#Create control file
intitialize_control()
control_add_package(description="Aquila DSP library")
control_add_package("dev",
    arch_specific=False,
    description="Aquila DSP library (development files)")

#Build it
commandline_interface()
