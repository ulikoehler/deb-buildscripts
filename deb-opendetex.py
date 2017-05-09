#!/usr/bin/env python3
from deblib import *
# General config
set_name("opendetex")
set_homepage("https://github.com/pkubowicz/opendetex")
#Download it
pkgversion = "2.8.2"
git_clone("https://github.com/pkubowicz/opendetex.git", branch="v" + pkgversion)
set_version(pkgversion)
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
build_config_autotools(configure=False)
build_config["install"] = ["mkdir -p debian/opendetex/usr/bin/ && cp detex debian/opendetex/usr/bin/"]
write_rules()

#Create control file
intitialize_control()
control_add_package(description="OpenDetex TeX/LaTeX plaintext extractor")

#Build it
commandline_interface()
