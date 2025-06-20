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
build_env = {}
force_parallel = None # int if CLI flag is set

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
        gitrev = cmd_output(f"git rev-list --all | wc -l").decode("utf-8")
        version += f"-git{gitrev.strip()}"

def add_version_suffix(suffix):
    """
    Add a suffix to the current version.
    Modifies the source version. Call before set_debversion()
    """
    global version
    version += suffix

def set_debversion(arg):
    global debversion
    debversion = f"{get_version()}-{arg}"

def set_homepage(arg):
    global homepage
    homepage = arg

def cmd(arg, cwd=True):
    if cwd:
        arg = f"cd {get_name()} && {arg}"
    subprocess.run(arg, shell=True)

def cmd_output(arg, cwd=True):
    if cwd:
        arg = f"cd {get_name()} && {arg}"
    return subprocess.check_output(arg, shell=True)

def remove_old_buildtree():
    if os.path.exists(get_name()):
        shutil.rmtree(get_name())

def git_clone_to(url, directory, depth=None, branch=None):
    if not os.path.exists(directory):
        args = ["git", "clone", url, directory]
        if depth:
            args += ["--depth", str(depth)]
        if branch:
            args += ["--branch", branch]
        subprocess.run(args)


def git_clone(url, depth=None, branch=None):
    # Clone to _git directory to avoid multiple cloning
    remove_old_buildtree()
    git_clone_to(url, get_name() + "_git", depth=depth, branch=branch)
    # Copy _git tree to build dir
    shutil.copytree(get_name() + "_git", get_name(), symlinks=True)

def git_update_submodules():
    cmd_output("git submodule update --init --recursive")

def extract_compressed_archve(filename):
    """
    Run "tar xz?f" on the given filename and return the output
    """
    if filename.endswith(".zip"):
        out = subprocess.check_output(["unzip", filename])
        filtlines = [l.partition(":")[2] for l in out.decode("utf-8").split("\n")]
        return "\n".join(filtlines).encode("utf-8")
    # else: assume tar
    if filename.endswith((".tar.gz", ".tgz")):
        arg = "xzvf"
    elif filename.endswith((".tar.bz2", ".tbz")):
        arg = "xjvf"
    elif filename.endswith(".tar.xz"):
        arg = "xJvf"
    else:
        raise PackagingError("Don't know how to extract archive (unknown extension): " + filename)
    return  subprocess.check_output(["tar", arg, filename])

def find_most_common_prefix(txt):
    """
    Find the most common prefix (prefix is partitioned by /)
    in txt split into lines
    """
    outlines = (line.strip() for line in txt.decode("utf-8").split("\n"))
    ctr = Counter()
    for line in outlines:
        ctr[line.partition("/")[0]] += 1
    return ctr.most_common()[0][0]

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
        print(f"Skipping download - file {filename} already exists")
    # Find the most common output prefix of the tar output = the directory name
    prefix = find_most_common_prefix(extract_compressed_archve(filename))
    # Rename to the directory name the rest of the code expects
    os.rename(prefix, get_name())

def remove_metadata_directories(directory, keep_git=False, keep_debian=False):
    """
    Remove subdirectories of directory like .git or debian
    """
    # Remove .git & old build directory
    if not keep_git:
        shutil.rmtree(os.path.join(directory, ".git"), ignore_errors=True)
    if not keep_debian:
        shutil.rmtree(os.path.join(directory, "debian"), ignore_errors=True)

def pack_source(ext="xz", keep_git=False):
    remove_metadata_directories(get_name(), keep_git=keep_git)
    # Pack source archive
    outfilename = f"{get_name()}_{get_version()}.orig.tar.{ext}"
    # Delete old archive if it exist
    if os.path.isfile(outfilename):
        os.remove(outfilename)
    # Create new archive
    opt = {"xz": "cJvf", "gz": "czvf", "bz2": "cjvf"}[ext]
    cmd_output(f"tar {opt} {outfilename} {get_name()}", cwd=False)

def debian_dirpath():
    return os.path.join(get_name(), "debian")

def create_debian_dir():
    os.makedirs(debian_dirpath(), exist_ok=True)

def copy_license(filename=None):
    dst = os.path.join(debian_dirpath(), "copyright")
    if filename is None:
        for filename in ["COPYING", "LICENSE", "License.txt", "license.txt", "LICENSE.txt", "COPYRIGHT", "LICENSE.md"]:
            fn = os.path.join(get_name(), filename)
            if os.path.isfile(fn):
                shutil.copy(fn, dst)
                return
        raise PackagingError("Can't find license file!")
    else: # Known filename
        shutil.copy(os.path.join(get_name(), filename), dst)

def create_debian():
    "Create the debian directory. Call this AFTER setting all config options"

def create_dummy_changelog():
    arg = "dch --create -v {} --package {} \"\" && dch -r \"\""
    cmd(arg.format(get_debversion(), get_name()))

def intitialize_control():
    with open(control_filepath(), "w") as outfile:
        print(f"Source: {get_name()}", file=outfile)
        print("Maintainer: None <none@example.com>", file=outfile)
        print("Section: misc", file=outfile)
        print("Priority: optional", file=outfile)
        print("Standards-Version: 3.9.2", file=outfile)
        print(f"Build-Depends: {', '.join(['debhelper (>= 8)'] + build_depends)}", file=outfile)

def get_dpkg_architecture():
    """
    Get the dpkg architecture, e.g. amd64
    """
    arch = cmd_output("dpkg-architecture | grep DEB_BUILD_ARCH=", cwd=False)
    arch = arch.decode("utf-8").strip().rpartition("=")[2]
    return arch

def control_filepath():
    return os.path.join(debian_dirpath(), "control")

def control_add_package(suffix=None, depends=[], provides=[], conflicts=[], arch_specific=True, description=None, only_current_arch=False):
    global homepage
    package_name = get_name()
    if suffix:
        package_name += f"-{suffix}"
    arch = "any" if arch_specific else "all"
    if only_current_arch: # Force e.g. amd64 for prebuilt stufff
        arch = get_dpkg_architecture()
    # Auto-determine some deps for 
    if arch_specific:
        depends += ["${shlibs:Depends}", "${misc:Depends}"]
    # Append to control file
    with open(control_filepath(), "a") as outfile:
        print("", file=outfile)
        print(f"Package: {package_name}", file=outfile)
        print(f"Architecture: {arch}", file=outfile)
        if depends:
            print(f"Depends: {', '.join(depends)}", file=outfile)
        if provides:
            print(f"Provides: {', '.join(provides)}", file=outfile)
        if conflicts:
            print(f"Conflicts: {', '.join(provides)}", file=outfile)
        if homepage:
            print(f"Homepage: {homepage}", file=outfile)
        if description:
            print(f"Description: {description}", file=outfile)

def init_misc_files():
    """
    Write miscellaneous files:
      - debian/compat
      - debian/source/format
    """
    os.makedirs(os.path.join(debian_dirpath(), "source"))
    with open(os.path.join(debian_dirpath(), "compat"), "w") as outf:
        outf.write("10")
    with open(os.path.join(debian_dirpath(), "source", "format"), "w") as outf:
        outf.write("3.0 (quilt)")

def parallelism():
    if force_parallel is not None:
        return force_parallel
    try:
        return os.cpu_count()
    except: # <= python 3.4
        return 2

def build_config_cmake(targets=["all"], cmake_opts=[], install_cmd="make install", srcdir="."):
    """
    Configure the build for cmake
    """
    global build_depends
    build_config["configure"] = [
        f"cmake {srcdir} -DCMAKE_INSTALL_PREFIX=debian/{get_name()}/usr {' '.join(cmake_opts)}"
    ]
    build_config["build"] = [
        f"make {' '.join(targets)} -j{parallelism()}"
    ]
    build_config["install"] = [
        f"mkdir -p debian/{get_name()}/usr",
        install_cmd
    ]
    build_depends.append("cmake")
    
def build_config_go():
    """
    Configure the build for cmake
    """
    global build_depends
    global build_env
    build_env["GOCACHE"] = "/tmp/go-cache"
    build_env["GOMODCACHE"] = "/tmp/gomod-cache"
    build_depends.append("golang-go")
    build_config["configure"] = [
        "go mod download",
    ]
    build_config["build"] = [
        f"go build -o {get_name()}"
    ]
    build_config["install"] = [
        f"mkdir -p debian/{get_name()}/usr/bin",
        f"mv {get_name()} debian/{get_name()}/usr/bin/",
    ]
    build_depends.append("cmake")

def build_config_just_make(targets=["all"], cmake_opts=[], install_cmd="make install", srcdir="."):
    """
    Configure the build for make without configuration step
    """
    global build_depends
    build_config["configure"] = []
    build_config["build"] = [
        f"make {' '.join(targets)} -j{parallelism()}"
    ]
    build_config["install"] = [
        f"mkdir -p debian/{get_name()}/usr",
        install_cmd
    ]
    build_depends.append("cmake")


def build_config_python(python="python3"):
    """
    Configure the build for cmake
    """
    global build_depends
    build_config["clean"] = []
    build_config["build"] = ["python setup.py build"]
    build_config["install"] = [
        f"{python} setup.py install --prefix=debian/{get_name()}/usr"
    ]


def build_config_autotools(targets=["all"], cfg_flags=[], install_cmd="make install", configure=True):
    """
    Configure the build for cmake
    """
    global build_depends
    # Auto-regenerate ./configure
    if os.path.isfile(os.path.join(get_name(), "autogen.sh")) and not \
       os.path.isfile(os.path.join(get_name(), "configure")):
        build_config["configure"].append("./autogen.sh")
        build_depends.append("libtool")

    build_config["configure"].append(f"mkdir -p debian/{get_name()}/usr")
    if configure:
        build_config["configure"].append(
            f"./configure --prefix=`pwd`/debian/{get_name()}/usr {''.join(cfg_flags)}"
        )
    build_config["build"] = [
        f"make {' '.join(targets)} -j{parallelism()}"
    ]
    build_config["install"] = [
        install_cmd
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
    # avoid dirname only removing trailing slash
    if src.endswith("/"):
        src = src[:-1]
    # Dont add mkdir twice
    mkdir = f"mkdir -p debian/{get_name()}-{suffix}/{os.path.dirname(src)}"
    if mkdir not in build_config["install"]:
        build_config["install"].append(mkdir)
    # Add move command
    build_config["install"].append(
        f"mv debian/{get_name()}/{src} debian/{get_name()}-{suffix}/{os.path.dirname(src)}"
    )

def install_move(src, dst, suffix):
    """
    A more flexible version of install_usr_dir_to_package().
    Allows arbitrary destination paths

    move_usr_dir_to_package("usr/lib/foobar.d", "usr/lib/foobar", "dev")
    moves the /usr/lib/foobar.d folder to <name>-dev/usr/lib/foobar/

    Note that you can move files, but you must not specify the filename as dst but the target
    directory!
    """
    # Dont add mkdir twice
    mkdir = f"mkdir -p debian/{get_name()}-{suffix}/{dst}"
    if mkdir not in build_config["install"]:
        build_config["install"].append(mkdir)
    # Add move command
    build_config["install"].append(
        f"mv debian/{get_name()}/{src} debian/{get_name()}-{suffix}/{dst}"
    )

def install_file(src, dst, suffix=None):
    """
    Copy arbitrary files from the project directory.

    Call after build_config_...()

    install_copy_file("lib/foo.so", "usr/lib/")
    copies lib/foo.so from the project dir to <name>/usr/lib/
    """
    dstproj = get_name() if suffix is None else get_name() + "-" + suffix
    # Dont add mkdir twice
    mkdir = f"mkdir -p debian/{dstproj}/{dst}"
    if mkdir not in build_config["install"]:
        build_config["install"].append(mkdir)
    # Add move command
    build_config["install"].append(
        f"cp -rv {src} debian/{dstproj}/{dst}"
    )

def write_rules():
    """
    Call after all rule configurations
    """
    with open(os.path.join(debian_dirpath(), "rules"), "w", encoding="utf-8") as outf:
        print('#!/usr/bin/make -f', file=outf)
        for key, value in build_env.items():
            print(f'export {key}={value}', file=outf)
        if build_env:
            print("", file=outf)
        print('%:\n\tdh $@', file=outf)
        for key, cmds in build_config.items():
            print(f'override_dh_auto_{key}:', file=outf)
            for cmd in cmds:
                print(f'\t{cmd}', file=outf)

def perform_debuild(only_source=False):
    # Create misc files
    init_misc_files()
    cmd("debuild -S -uc" if only_source else "debuild -us -uc -b")

def commandline_interface():
    """
    Provides a CLI interface and runs perform_debuild with option
    """
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--only-source", action="store_true",
        help="Dont build packages, only source (for PPA)")
    parser.add_argument("-j", "--threads", type=int, default=None,
        help="The number of threads to use")
    args = parser.parse_args()

    if args.threads is not None:
        force_parallel = args.threads

    perform_debuild(only_source=args.only_source)

def add_build_dependencies(*args):
    global build_depends
    build_depends += args

def depends_main_package():
    """
    Returns a depends element for the main package
    with the given version
    """
    return f"{get_name()} (= {get_debversion()})"

def distribution_name():
    """
    Get the LSB release distribution name, e.g. "xenial" on Ubuntu 16.04
    """
    return subprocess.check_output("lsb_release -c -s", shell=True).strip().decode("utf-8")
