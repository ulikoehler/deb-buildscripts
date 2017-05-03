#!/usr/bin/env python3
from deblib import *
# General config
set_name("libczmq4")
set_homepage("http://czmq.zeromq.org")
#Download it
pkgversion = "4.0.2"
set_version(pkgversion + "-deb1")
git_clone("https://github.com/zeromq/czmq.git", branch="v{}".format(pkgversion))
set_debversion(1)
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

build_depends += ["libzmq5-dev", "libzmq5"]

#Create control file
intitialize_control()
control_add_package(
    provides=["libczmq1", "libczmq", "libczmq2", "libczmq3"],
    depends=["libzmq5"],
    description="ZeroMQ (0MQ) lightweight messaging kernel CZMQ binding")
control_add_package("dev",
    provides=["libczmq-dev", "libczmq1-dev", "libczmq2-dev", "libczmq3-dev"],
    depends=[depends_main_package(), "libzmq5-dev"],
    arch_specific=False,
    description="ZeroMQ (0MQ) lightweight messaging kernel CZMQ binding (development files)")
control_add_package("doc",
    provides=["libczmq-doc", "libczmq1-doc", "libczmq3-doc", "libczmq2-doc"],
    arch_specific=False,
    description="ZeroMQ (0MQ) lightweight messaging kernel CZMQ binding (documentation)")

#Build it
commandline_interface()
