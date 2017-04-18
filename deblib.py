#!/usr/bin/env python3
"""
deb-buildscripts main python library

Contains basic functionality to build deb packages from scratch
"""
import subprocess
import shutil
import os
from collections import defaultdict, Counter

class PackagingError(Exception):
    pass

name = ""
version = None
debversion = None
homepage = None
build_depends = []

# Key (suffix to override_dh_auto_) ; value: list of make commands
build_config = defaultdict(list)

def get_name():
    global name
    if name == None:
        raise PackagingError("No name set (set_name())")
    return name

def set_name(arg):
    global name
    name = arg

def get_version():
    global version
    if version == None:
        raise PackagingError("No version set (set_version())")
    return version

def get_debversion():
    global debversion
    if debversion == None:
        raise ValueError("No debversion set (set_debversion())")
    return debversion

def set_version(arg, gitcount=False):
    global version
    version = arg
    if gitcount:
        gitrev = cmd_output("git rev-list --all | wc -l".format(get_name())).decode("utf-8")
        version += "-{}".format(gitrev.strip())

def set_debversion(arg):
    global debversion
    debversion = "{}-{}".format(get_version(), arg)

def set_homepage(arg):
    global homepage
    homepage = homepage

def cmd(arg, cwd=True):
    if cwd:
        arg = "cd {} && {}".format(get_name(), arg)
    subprocess.run(arg, shell=True)

def cmd_output(arg, cwd=True):
    if cwd:
        arg = "cd {} && {}".format(get_name(), arg)
    return subprocess.check_output(arg, shell=True)

def remove_old_buildtree():
    if os.path.exists(get_name()):
        shutil.rmtree(get_name())

def git_clone(url, depth=None, branch=None):
    remove_old_buildtree()
    args = ["git", "clone", url, get_name()]
    if depth:
        args += ["--depth", str(depth)]
    if branch:
        args += ["--branch", branch]
    subprocess.run(args)

def wget_download(url):
    """
    Download a package from a wget-compatible URL
    """
    remove_old_buildtree()
    # Extract filename
    filename = url.rpartition("/")[2].partition("?")[0]
    # Download
    if not os.path.isfile(filename):
        args = ["wget", url]
        subprocess.run(args)
    else:
        print("Skipping download - file {} already exists".format(filename))
    # Extract
    if filename.endswith(".tar.gz"):
        out = subprocess.check_output(["tar", "xzvf", filename])
    elif filename.endswith(".tar.bz2"):
        out = subprocess.check_output(["tar", "xjvf", filename])
    elif filename.endswith(".tar.xz"):
        out = subprocess.check_output(["tar", "xJvf", filename])
    else:
        raise PackagingError("Cant extract archive: " + filename)
    # Find the most common output prefix of the tar output = the directory name
    outlines = [line.strip() for line in out.decode("utf-8").split("\n")]
    ctr = Counter()
    for line in outlines:
        ctr[line.partition("/")[0]] += 1
    prefix = ctr.most_common()[0][0]
    # Rename to the directory name the rest of the code expects
    os.rename(prefix, get_name())

def pack_source():
    # Remove .git & old build directory
    shutil.rmtree(os.path.join(get_name(), ".git"), ignore_errors=True)
    shutil.rmtree(os.path.join(get_name(), "debian"), ignore_errors=True)
    # Pack source archive
    outfilename = "{}_{}.orig.tar.xz".format(get_name(), get_version())
    # Delete old archive if it exist
    if os.path.isfile(outfilename):
        os.remove(outfilename)
    # Create new archive
    cmd_output("tar cJvf {} {}".format(
        outfilename, get_name()), cwd=False)

def debian_dirpath():
    return os.path.join(get_name(), "debian")

def create_debian_dir():
    os.makedirs(debian_dirpath(), exist_ok=True)

def copy_license():
    dst = os.path.join(debian_dirpath(), "copyright")
    for filename in ["COPYING", "LICENSE"]:
        fn = os.path.join(get_name(), filename)
        if os.path.isfile(fn):
            shutil.copy(fn, dst)
            return
    raise PackagingError("Can't find license file!")

def create_debian():
    "Create the debian directory. Call this AFTER setting all config options"

def create_dummy_changelog():
    arg = "dch --create -v {} --package {} \"\" && dch -r \"\""
    cmd(arg.format(get_debversion(), get_name()))

def intitialize_control():
    with open(control_filepath(), "w") as outfile:
        print("Source: {}".format(get_name()), file=outfile)
        print("Maintainer: None <none@example.com>", file=outfile)
        print("Section: misc", file=outfile)
        print("Priority: optional", file=outfile)
        print("Standards-Version: 3.9.2", file=outfile)
        print("Build-Depends: {}".format(", ".join(
            ["debhelper (>= 8)"] + build_depends)), file=outfile)

def get_dpkg_architecture():
    """
    Get the dpkg architecture, e.g. amd64
    """
    arch = cmd_output("dpkg-architecture | grep DEB_BUILD_ARCH=", cwd=False)
    arch = arch.decode("utf-8").strip().rpartition("=")[2]
    return arch

def control_filepath():
    return os.path.join(debian_dirpath(), "control")

def control_add_package(suffix=None, depends=[], provides=[], arch_specific=True, description=None, only_current_arch=False):
    global homepage
    package_name = get_name()
    if suffix:
        package_name += "-" + suffix
    arch = "any" if arch_specific else "all"
    if only_current_arch: # Force e.g. amd64 for prebuilt stufff
        arch = get_dpkg_architecture()
    # Auto-determine some deps for 
    if arch_specific:
        depends += ["${shlibs:Depends}", "${misc:Depends}"]
    # Append to control file
    with open(control_filepath(), "a") as outfile:
        print("", file=outfile)
        print("Package: " + package_name, file=outfile)
        print("Architecture: " + arch, file=outfile)
        if depends:
            print("Depends: " + ", ".join(depends), file=outfile)
        if provides:
            print("Provides: " + ", ".join(provides), file=outfile)
        if homepage:
            print("Homepage: " + homepage, file=outfile)
        if description:
            print("Description: " + description, file=outfile)

def init_misc_files():
    """
    Write miscellaneous files:
      - debian/compat
      - debian/source/format
    """
    os.makedirs(os.path.join(debian_dirpath(), "source"))
    with open(os.path.join(debian_dirpath(), "compat"), "w") as outf:
        outf.write("8")
    with open(os.path.join(debian_dirpath(), "source", "format"), "w") as outf:
        outf.write("3.0 (quilt)")

def parallelism():
    try:
        return os.cpu_count()
    except: # <= python 3.4
        return 2

def build_config_cmake(targets=["all"], cmake_opts=[]):
    """
    Configure the build for cmake
    """
    global build_depends
    build_config["configure"] = [
        "cmake . -DCMAKE_INSTALL_PREFIX=debian/{}/usr {}".format(
            get_name(), " ".join(cmake_opts))
    ]
    build_config["build"] = [
        "make {} -j{}".format(
            " ".join(targets), parallelism())]
    build_config["install"] = [
        "mkdir -p debian/{}/usr".format(get_name()),
        "make install"
    ]
    build_depends.append("cmake")


def build_config_autotools(targets=["all"], cfg_flags=[]):
    """
    Configure the build for cmake
    """
    global build_depends
    # Auto-regenerate ./configure
    if os.path.isfile(os.path.join(debian_dirpath(), "autogen.sh")):
        build_config["configure"].append("./autogen.sh")
    build_config["configure"] += [
        "mkdir -p debian/{}/usr".format(get_name()),
        "./configure --prefix=`pwd`/debian/{}/usr {}".format(get_name(), "".join(cfg_flags))
    ]
    build_config["build"] = [
        "make {} -j{}".format(
            " ".join(targets), parallelism())]
    build_config["install"] = [
        "make install"
    ]
    build_depends += ["autoconf", "automake"]

def test_config(arg):
    """Configure a command to run for testing"""
    build_config["test"] = [arg]

def install_usr_dir_to_package(src, suffix):
    """
    Use this to e.g. move the include dir from the main package
    directory where it was installed.

    src is relative to the install directory, not the project directory

    Call after build_config_...()

    move_usr_dir_to_package("usr/include", "dev")
    moves the /usr/include folder to <name>-dev/usr/
    """
    # Dont add mkdir twice
    mkdir = "mkdir -p debian/{}-{}/usr/".format(get_name(), suffix)
    if mkdir not in build_config["install"]:
        build_config["install"].append(mkdir)
    # Add move command
    build_config["install"].append(
        "mv debian/{}/{} debian/{}-{}/usr/".format(
            get_name(), src, get_name(), suffix)
    )

def install_file(src, dst, suffix=None):
    """
    Copy arbitrary files from the project directory

    Call after build_config_...()

    install_copy_file("lib/foo.so", "usr/lib/")
    copies lib/foo.so from the project dir to <name>/usr/lib/
    """
    dstproj = get_name() if suffix is None else get_name() + "-" + suffix
    # Dont add mkdir twice
    mkdir = "mkdir -p debian/{}/{}".format(dstproj, dst)
    if mkdir not in build_config["install"]:
        build_config["install"].append(mkdir)
    # Add move command
    build_config["install"].append(
        "cp {} debian/{}/{}".format(src, dstproj, dst)
    )

def write_rules():
    """
    Call after al
    """
    with open(os.path.join(debian_dirpath(), "rules"), "w") as outf:
        print('#!/usr/bin/make -f', file=outf)
        print('%:', file=outf)
        print('\tdh $@', file=outf)
        for key, cmds in build_config.items():
            print('override_dh_auto_{}:'.format(key), file=outf)
            for cmd in cmds:
                print('\t{}'.format(cmd), file=outf)

def perform_debuild(only_source=False):
    # Create misc files
    init_misc_files()
    cmd("debuild -S -uc" if only_source else "debuild -us -uc")

def commandline_interface():
    """
    Provides a CLI interface and runs perform_debuild with option
    """
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--only-source", action="store_true",
        help="Dont build packages, only source (for PPA)")
    args = parser.parse_args()

    perform_debuild(only_source=args.only_source)
