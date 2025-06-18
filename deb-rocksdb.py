#!/usr/bin/env python3
from deblib import *
# General config
set_name("librocksdb")
set_homepage("http://rocksdb.org/")
#Download it
pkgversion = "10.2.1"
set_version(pkgversion)
add_version_suffix("-deb1")
git_clone("https://github.com/facebook/rocksdb.git", branch="v" + pkgversion, depth=1)
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

instcmd = f"DESTDIR=debian/{get_name()}/usr make install-headers install-shared"
# Create rules file
build_config_autotools(targets=[""], install_cmd=instcmd)
install_usr_dir_to_package("usr/include", "dev")
build_config["test"] = []
build_config["clean"] = []
build_config["build"] = ["make -j12 shared_lib"]
build_config["configure"] = [f"mkdir -p debian/{get_name()}/usr/include",]
write_rules()

build_depends += ["zlib1g-dev", "libbz2-dev", "libsnappy-dev", "libgflags-dev", "libzstd-dev"]

#Create control file
intitialize_control()
control_add_package(
    depends=["libbz2-1.0", "libsnappy1v5 (>= 1.0)", "zlib1g", "libgflags2.2"],
    description="RocksDB Key-Value database")

control_add_package("dev",
    depends=[depends_main_package()],
    arch_specific=False,
    description="RocksDB Key-Value database (development files)")

#Build it
commandline_interface()
