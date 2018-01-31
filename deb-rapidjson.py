#!/usr/bin/env python3
from deblib import *
# General config
set_name("rapidjson")
set_homepage("https://github.com/zsiciarz/aquila")
#Download it
git_clone("https://github.com/Tencent/rapidjson.git")
set_version("1.1.0", gitcount=False)
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
build_config_cmake(cmake_opts=[
    "-DRAPIDJSON_BUILD_EXAMPLES=off",
    "-DRAPIDJSON_BUILD_THIRDPARTY_GTEST=off",
    "-DRAPIDJSON_BUILD_TESTS=off"
])
install_usr_dir_to_package("usr/include", "dev")
write_rules()

#Create control file
intitialize_control()
# header only => no dev package
control_add_package("dev",
    arch_specific=False,
    description="RapidJSON JSON parser and generator (development files)")

#Build it
commandline_interface()
