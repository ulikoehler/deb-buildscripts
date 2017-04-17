#!/usr/bin/env python3
set_name("libaquila")
set_homepage("https://github.com/zsiciarz/aquila")
#Download it
git_clone("https://github.com/zsiciarz/aquila.git")
set_version(3.0.0, gitcount=True)
set_debversion(1)
# Remove git
pack_source()
create_debian_dir()
#Use the existing COPYING file
copy_license()
#Create the changelog (no messages - dummy)
create_dummy_changelog()

#Rules files
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\tcmake . -DCMAKE_INSTALL_PREFIX=debian/$NAME/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake all aquila_test' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr" >> debian/rules
echo -e "\tmake install" >> debian/rules
echo -e "\tcp lib/libOoura_fft.a debian/$NAME/usr/lib" >> debian/rules
echo -e "\tmkdir -p debian/$NAME-dev/usr/ && mv debian/$NAME/usr/include debian/$NAME-dev/usr/" >> debian/rules

# Create rules file
build_config_cmake()
test_config("make aquila_test")
install_file("lib/libOoura_fft.a", "usr/lib")
install_usr_dir_to_package("usr/include", "dev")
write_rules()

#Create control file
intitialize_control()
control_add_package(description="Aquila DSP library")
control_add_package("-dev",
    arch_specific=False,
    description="Aquila DSP library (development files)")

#Create some misc files
init_misc_files()
#Build it
perform_debuild()
