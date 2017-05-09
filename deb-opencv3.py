#!/usr/bin/env python3
from deblib import *
# General config
set_name("libopencv3")
set_homepage("http://opencv.willowgarage.com/")
#Download it
pkgversion = "3.2.0"
set_version(pkgversion)
add_version_suffix("-deb15")
git_clone("https://github.com/Itseez/opencv.git", branch=pkgversion, depth=1)
# Clone opencv_contrib to main source directory
contrib_dirname = get_name() + "/opencv_contrib"
git_clone_to("https://github.com/opencv/opencv_contrib.git", contrib_dirname, branch=pkgversion, depth=1)
remove_metadata_directories(contrib_dirname)

# Download intel ICV
icv_commit = "81a676001ca8075ada498583e4166079e5744668"
icv_hash = "808b791a6eac9ed78d32a7666804320e"
icv_filename = "ippicv_linux_20151201.tgz"
icv_url = "https://raw.githubusercontent.com/opencv/opencv_3rdparty/{}/ippicv/{}".format(icv_commit, icv_filename)
icv_path  = "{}/3rdparty/ippicv/downloads/linux-{}/{}".format(get_name(), icv_hash, icv_filename)
icv_dst = "{}/3rdparty/ippicv/".format(get_name())
print("Downloading Intel ICV")
os.makedirs(os.path.dirname(icv_path), exist_ok=True)
subprocess.call(["wget", "-O", icv_path, icv_url])
subprocess.call(["tar", "xzvf", icv_path])
subprocess.call("mv ippicv_lnx/* " + icv_dst, shell=True)
# Remove download tree & local ippicv directory
shutil.rmtree(icv_dst + "downloads")
shutil.rmtree("ippicv_lnx")

# Patch:
cmd("sed -i -e '/downloader.cmake/s/^/#/g' cmake/OpenCVFindIPP.cmake".format())

# Move all the sources to a subdir to simulate an out-of-source build
os.makedirs("opencv_tmp")
subprocess.call(["mv", get_name(), "opencv_tmp"])
os.rename("opencv_tmp", get_name())

set_debversion(1)
# Remove git
pack_source("gz")
create_debian_dir()

#Use the existing COPYING file
copy_license(os.path.join(get_name(), get_name(), "LICENSE"))

#Create the changelog (no messages - dummy)
create_dummy_changelog()

instcmd = "INSTALL_PATH=debian/{}/usr make install-shared".format(get_name())
# Create rules file
build_config_cmake(targets=["all", "doxygen"], srcdir=get_name(), cmake_opts=[
    "-DIPPROOT=3rdparty/ippicv",
    "-DCMAKE_BUILD_TYPE=RELEASE",
    "-DENABLE_PRECOMPILED_HEADERS=OFF",
    "-DWITH_CUDA=OFF",
    "-DWITH_OPENGL=ON",
    "-DWITH_TBB=ON",
    "-DWITH_GDAL=ON",
    "-DBUILD_EXAMPLES=OFF",
    "-DOPENCV_EXTRA_MODULES_PATH={}/opencv_contrib/modules".format(get_name())
], install_cmd=instcmd)

# Move dirs to the correct packages
install_move("usr/include", "usr/share/OpenCV", "dev")
install_move("usr/share/OpenCV/3rdparty", "usr/share/OpenCV", "3rdparty")
install_move("usr/share/OpenCV/doc", "usr/share/OpenCV", "doc")
install_move("usr/share/OpenCV/samples", "usr/share/OpenCV", "doc")
install_move("usr/lib/python2*", "usr/lib", "python2")
install_move("usr/lib/python3*", "usr/lib", "python3")
# Install other files
install_file("3rdparty/ippicv/ippicv_lnx/lib/intel64/libippicv.a", "usr/lib", suffix="dev")
install_usr_dir_to_package("usr/include", "doc")
write_rules()

# This is a larger list of build depends, so its separated into parts
pkgs_build_tools=["build-essential", "cmake", "libprotobuf-dev"]
pkgs_viz=["libgtkglext1-dev", "libvtk6-dev", "vtk6"]
pkgs_img=["zlib1g-dev", "libjpeg-dev", "libwebp-dev", "libpng-dev", "libtiff5-dev", "libjasper-dev", "libopenexr-dev", "libgdal-dev"]
pkgs_video=["libdc1394-22-dev", "libavcodec-dev", "libavformat-dev", "libswscale-dev", "libtheora-dev", "libvorbis-dev", "libxvidcore-dev", "libx264-dev", "yasm", "libopencore-amrnb-dev", "libopencore-amrwb-dev", "libv4l-dev", "libxine2-dev"]
pkgs_math=["libtbb-dev", "libeigen3-dev"]
pkgs_python=["python-dev", "python-tk", "python-numpy", "python3-dev", "python3-tk", "python3-numpy"]
pkgs_util=["unzip", "wget", "doxygen", "protobuf-compiler"]
pkgs_ocr=["libtesseract-dev"]
pkgs_doc=["texlive-full"]
build_depends += pkgs_build_tools + pkgs_viz + pkgs_img + pkgs_video + pkgs_math + pkgs_python + pkgs_util + pkgs_ocr + pkgs_doc

#Create control file
intitialize_control()
control_add_package(
    conflicts=["libopencv-dev", "libcv-dev", "libopencv-contrib-dev"],
    description="OpenCV")

control_add_package("dev",
    depends=[depends_main_package()],
    arch_specific=False,
    description="OpenCV (development files)")

control_add_package("doc",
    depends=[depends_main_package()],
    arch_specific=False,
    description="OpenCV (documentation)")

control_add_package("python2",
    depends=[depends_main_package()],
    arch_specific=True,
    description="OpenCV (Python2 bindings)")

control_add_package("python3",
    depends=[depends_main_package()],
    arch_specific=True,
    description="OpenCV (Python3 bindings)")

#Build it
commandline_interface()
