#!/usr/bin/env python3
from deblib import *
# General config
set_name("libopengv")
set_homepage("https://github.com/laurentkneip/opengv")
#Download it
git_clone("https://github.com/laurentkneip/opengv.git")
set_version("1.0", gitcount=True)
add_version_suffix("-deb1")
set_debversion(1)

pack_source()
create_debian_dir()

add_build_dependencies(
    "libeigen3-dev",
    "libboost-python-dev",
    "python-numpy"
)

#Use the existing COPYING file
copy_license()

#Create the changelog (no messages - dummy)
create_dummy_changelog()

# Create rules file
build_config_cmake(cmake_opts=["-DBUILD_PYTHON=ON"])
install_usr_dir_to_package("usr/include", "dev")
install_usr_dir_to_package("usr/CMake", "dev")
install_usr_dir_to_package("usr/lib/python2.7", "python")
build_config["configure"].append(
    "echo 'add_definitions(\"-std=gnu++11\")' >> python/CMakeLists.txt"
)
write_rules()

#Create control file
intitialize_control()
control_add_package(description="OpenGV geometry view library")
control_add_package("dev",
    depends=[depends_main_package()],
    arch_specific=False,
    description="OpenGV geometry view library (development files)")
control_add_package("python",
    arch_specific=True,
    depends=["python", "python-numpy"],
    description="OpenGV geometry view library (python bindings)")

#Build it
commandline_interface()
