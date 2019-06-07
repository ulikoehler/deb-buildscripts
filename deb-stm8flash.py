#!/usr/bin/env python3
from deblib import *
# General config
set_name("stm8flash")
remove_old_buildtree()
set_homepage("https://github.com/vdudouyt/stm8flash.git")
#Download it
git_clone("https://github.com/vdudouyt/stm8flash.git")
set_version("0.1", gitcount=True)
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
build_config_just_make(install_cmd=f"DESTDIR=debian/{get_name()} make install && mv debian/{get_name()}/usr/local/bin debian/{get_name()}/usr/bin")
#install_usr_dir_to_package("usr/include", "dev")
#install_usr_dir_to_package("usr/share", "doc")
write_rules()

build_depends += ["libusb-1.0-0-dev"]

#Create control file
intitialize_control()
control_add_package(description="STM8 SWIM flash utility")

#Build it
commandline_interface()
