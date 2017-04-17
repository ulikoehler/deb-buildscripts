# Debian package buildscripts

This repository contains a collection of self-contained scripts which can be used to download & build debian packages.

This is most useful when the version in official package repositories is outdated and you just want to build the package without worrying about complex build processes.

The script automatically
- Download the correct version of the package
- Unpack it
- Create the `debian` folder
- Build the package (including a `-dev` package)

### Installing dependencies

(only partially finished)

```sh
sudo apt-get install devscripts debhelper build-essential
```
Depending on the buildscript, you might need to install more packages.

### Building a debian buildscript

Simply run the buildscript, e.g.:

```sh
./deb-jemalloc.sh
```

If the build succeeds, this will create `.deb` packages. Else, look at the error messages, usually some packages are missing.

### Caveats

When building for a PPA, add

```
export DEBEMAIL=ukoehler@techoverflow.net
```
to your `.bashrc` or `.zshrc` and restart your shell.

### License

`deb-buildscripts` is published in the hope that it will be useful to someone.

The buildscripts (i.e. everything in this repository, but not neccessarily the software you can build using the scripts) are distributed under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0) (public domain).

deb-buildscripts were originally written by [Uli Köhler](http://techoverflow.net). Attribution is highly appreciated but not required in any form.
