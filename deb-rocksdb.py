#!/usr/bin/env python3
from deblib import *
# General config
set_name("librocksdb")
set_homepage("http://rocksdb.org/")
#Download it
pkgversion = "5.2.1"
<<<<<<< 0ed6e534a57d347c4106e479bd875eda35ebe477
set_version(pkgversion + "-deb5")
=======
set_version(pkgversion + "-deb4")
>>>>>>> More rocksdb fixes
git_clone("https://github.com/facebook/rocksdb.git", branch="v" + pkgversion, depth=1)
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

instcmd = "INSTALL_PATH=debian/{}/usr make install-shared".format(get_name())
# Create rules file
build_config_autotools(targets=[""], install_cmd=instcmd)
install_usr_dir_to_package("usr/include", "dev")
build_config["test"] = []
build_config["clean"] = []
build_config["build"] = ["PORTABLE=1 CFLAGS=-march=corei7 make -j4 shared_lib"]
build_config["configure"] = []
write_rules()

build_depends += ["zlib1g-dev", "libbz2-dev", "libsnappy-dev", "libgflags-dev"]

#Create control file
intitialize_control()
control_add_package(
    depends=["libbz2-1.0", "libsnappy1v5 (>= 1.0)", "zlib1g", "libgflags2v5"],
    description="RocksDB Key-Value database")

control_add_package("dev",
    depends=["{} (= {})".format(get_name(), get_debversion())],
    arch_specific=False,
    description="RocksDB Key-Value database (development files)")

#Build it
commandline_interface()
