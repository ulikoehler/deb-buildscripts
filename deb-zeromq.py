#!/usr/bin/env python3
from deblib import *
# General config
set_name("libzmq5")
set_homepage("http://zeromq.org")
#Download it
pkgversion = "4.2.1"
set_version(pkgversion + "-deb2")
wget_download("https://github.com/zeromq/libzmq/releases/download/v{}/zeromq-{}.tar.gz".format(pkgversion, pkgversion))
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

build_depends += ["libunwind8", "libunwind-dev", "zip", "libsodium-dev"]

#Create control file
intitialize_control()
control_add_package(
    provides=["libzmq1", "libzmq3", "libzmq4"],
    depends=["libsodium18", "libunwind8"],
    description="ZeroMQ (0MQ) lightweight messaging kernel")
control_add_package("dev",
    provides=["libzmq-dev", "libzmq1-dev", "libzmq3-dev", "libzmq4-dev"],
    depends=["{} (= {})".format(get_name(), get_debversion())],
    arch_specific=False,
    description="ZeroMQ (0MQ) lightweight messaging kernel (development files)")
control_add_package("doc",
    provides=["libzmq-doc", "libzmq1-doc", "libzmq3-doc", "libzmq4-dev"],
    arch_specific=False,
    description="ZeroMQ (0MQ) lightweight messaging kernel (documentation)")

#Build it
commandline_interface()
