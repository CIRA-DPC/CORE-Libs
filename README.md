# CORE Libraries
The CORE Libraries package is used to compile seven (eight for CentOS 8) packages that are required 
when building the CORE package for CloudSat algorithms. The various packages are compiled using the 
Intel OneAPI compilers by default.

NOTE: It should not be necessary for CloudSat developers to use this package directly, either in its 
source or binary forms. It is automatically downloaded and used in the build process for the CORE 
library.

## Supported OS and Architectures
This package has been tested on Mac OSX Catalina and Big Sur, CentOS 8, and Debian 10. For Linux 
only the x86 architecture has been tested. For Mac both x86 and the new M1 Arm64 architectures have 
been tested.

## Building the Libraries

### Building from Source
**There are currently issues with this relating to use of environment variables**
See this issue: https://bear.cira.colostate.edu/CloudSat-DPC/cloudsat/algorithms/core_libs/-/issues/3

Building form source requires the Intel OneAPI compilers for `ifort` and `icc`. Instructions on how 
to install these compilers can be found on the [Intel OneAPI page of the DPC wiki][wiki-oneapi].  To 
build the package:
- source the Intel environment:
  - For root installations: `. /opt/intel/oneapi/setvars.sh`
  - For user-specific installations: `. /opt/intel/oneapi/setvars.sh`
- (Debian) ensure that `m4` is installed: `apt-get install m4`
- clone this repository: `git clone git@bear.cira.colostate.edu:CloudSat-DPC/cloudsat/algorithms/core_libs.git`  - change directories 
  to the cloned repository: `cd core_libs`
- To build the libraries for local use: `make`
- To package them for distribution: `make package`

## Distribution

### Creating a Release
Before creating a new binary release, please create a new tag in the repository via `git tag` or the 
GitLab UI.  The tag should be a semantic version number (e.g. 2.1.3) and should be an increment 
higher than the previous tag.

To produce the files for distribution, we need to build for both the Intel and M1 chip 
architectures. To do this, please do the following on both an Intel Mac and an M1 Mac:

```
git clone git@bear.cira.colostate.edu:CloudSat-DPC/cloudsat/algorithms/core_libs.git
cd core_libs
./create_packages.sh
```

This will result in two `.tar.gz` files, one for "darwin" and one for "linux", in `./packages`.  
Their naming structure is `pname-pver-opsys-arch.tar.gz` where:
- `pname` is the package name (`core_libs`)
- `pver` is the package version which is set to the most recent tag in the package
  - If the most recent tag is on the current commit, only the tag will be used
  - If there have been commits since the most recent tag, additional information will be added to 
    the version to indicate how many additional commits there have been. These are not intended for 
    distribution.
- `opsys` is the operating system (either "darwin" or "linux")
- `arch` is the chip architecture (`x86_64` for Intel and `arm64` for M1)

### Distributing a Release
- Get an account on [https://io.cira.colostate.edu]() that is in the `CloudSat Developer` group.
- login to [https://io.cira.colostate.edu]()
- Then navigate to the `CORE Libaries` directory ([link](https://io.cira.colostate.edu/f/3447897))
- Upload the files either by dragging and dropping them or by clicking the `+` symbol at the top of 
  the page and selecting "Upload File"

## Downloading and Using Prebuilt Binaries

Prebuilt libraries can be found on [CIRA's NextCloud webpage][nextcloud-core-libs] as `.tar.gz` 
files. Each file contains only static libraries and their associated `include` files (e.g. `.h` and 
`.mod` files).

To use the prebuilt libraries to build [CORE](https://github.com/CIRA-DPC/CORE) itself, update the 
`CORE_LIBS_VERSION` variable in CORE's `Makefile`, then run `make` for CORE.  It will automatically 
detect your OS and download the appropriate prebuilt version of `core_libs`.

## Package Contents

This package contains seven (eight for CentOS 8) packages that are required for building the CORE 
package.  The packages are built in two main stages. First, the "Base Packages" are built then the 
"Main Packages".

### Base Packages - required before building HDF4 and HDF-EOS2
In the Make process, the following packages will be built and installed in `PREFIX` before HDF4 and 
HDF-EOS2 are built.

- libcirpc v1.3.1 | [home][hm-libtirpc] | [source code download][dl-libtirpc]
  - This is required for CentOS 8 and other similar linux flavors. This is required because `rpc` 
    has been removed from glibc as of version 2.32 which is used starting in Fedora 28, CentOS 8, 
    Alma 8, Red Hat 8, etc. [See here for more information][info-glibc-rpc-depr].
  - To support a single set of libraries for all Linux flavors, `libtirpc` is always built and the 
    system-level version of `rpc` or `libtirpc` is ignored.
- bison v3.8 | [home][hm-bison] | [source code download][dl-bison]
  - Must be built before `flex`.
- zlib v1.2.11 | [home][hm-zlib] | [source code download][dl-zlib]
- szip v2.1.1 | [home][hm-szip] | [source code download][dl-szip]
- flex v2.6.4 | [home][hm-flex] | [source code download][dl-flex]
  - Requires `bison`.
- jpeg v9d | [home][hm-jpeg] | [source code download][dl-jpeg]

### Main Packages
The "Main Packages" include HDF and HDF-EOS2. Before these packages can be built, the "Base 
Packages" must be built (handled in `Makefile`).

- hdf v4.2.15 | [home][hm-hdf] | [source code download][dl-hdf]
  - Required to build `hdf-eos2`.
- hdf-eos2 v3.0.0 | [home][hm-hdf-eos] | [source code download][dl-hdf-eos]
  - Requires `hdf` and uses `h4cc` as its C compiler and `h4fc` as its Fortran compiler. Both 
    compilers are binaries from the `hdf` package.

Dependencies are built from source using ifort and dpcpp from OneAPI.

## Notes

### "Fix" Poor Performance on Mac

On Macs that have XCode installed, the Intel compilers run very slowly. This is not true for Macs 
that only have Command Line Tools installed.

The issue is caused by xcodebuild being called multiple times per execution of the Intel compiler.  
A "fix" to this issue is provided below and comes from the last comment in [this 
thread][slow-intel-fix].

1. Create a file called `${HOME}/bin/xcodebuild` that contains the following:
   ```
   #!/bin/bash
   case "$4" in
       "")
         echo $INTEL_OSXSDK_VER;;
        *)
         echo $INTEL_OSXSDK_PATH;;
   esac
   ```

2. Set three environment variables (probably in your .bashrc).
   ```
   export INTEL_OSXSDK_VER=`xcodebuild -sdk macosx -version | grep SDKVersion`
   export INTEL_OSXSDK_PATH=`xcodebuild -sdk macosx -version Path`
   export PATH=${HOME}/bin:${PATH}
   ```

3. Restart your shell session.

### Developing on Mac: Disable Automatic Locale Detection

**It is not recommended to develop Docker images from a Mac due to the following issue. If you need 
to build from a Mac, see the "solutions" listed below.**

When on a Mac, running `docker build` for this image works fine. Something goes wrong when running a 
container from the image, then running `make clean; make base`. You get an error that looks like:

```
Catastrophic error: could not set locale "" to allow processing of multibyte characters
```

[This "solution" has worked for me](https://www.cdslab.org/paramonte/notes/troubleshooting/catastrophic-error-could-not-set-locale/)
but I'm not sure if it would have downstream impacts.

A potential solution that "should" work, but has not worked for me can be found here:
https://satyanash.net/software/2020/05/29/locale-issues-ssh-into-a-vm.html

<!-- Links -->
[hm-libtirpc]: https://git.linux-nfs.org/?p=steved/libtirpc.git
[dl-libtirpc]: https://sourceforge.net/projects/libtirpc/files/libtirpc/1.3.1/libtirpc-1.3.1.tar.bz2/download
[hm-bison]: https://www.gnu.org/software/bison/
[dl-bison]: http://ftp.gnu.org/gnu/bison/bison-3.8.tar.gz
[hm-zlib]: https://www.zlib.net/
[dl-zlib]: https://zlib.net/zlib-1.2.11.tar.gz
[hm-szip]: https://support.hdfgroup.org/doc_resource/SZIP/
[dl-szip]: https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz
[hm-flex]: https://github.com/westes/flex/
[dl-flex]: https://github.com/westes/flex/files/981163/flex-2.6.4.tar.gz
[hm-jpeg]: https://ijg.org/
[dl-jpeg]: https://ijg.org/files/jpegsrc.v9d.tar.gz

[hm-hdf]: http://portal.hdfgroup.org/display/HDF4/HDF4
[dl-hdf]: https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.15/src/hdf-4.2.15.tar.gz
[hm-hdf-eos]: http://hdfeos.org/
[dl-hdf-eos]: https://git.earthdata.nasa.gov/projects/DAS/repos/hdfeos/raw/hdf-eos2-3.0-src.tar.gz?at=3128a738021501c821549955f6c78348e5f33850

[info-glibc-rpc-depr]: https://sourceware.org/pipermail/libc-announce/2020/000029.html
[nextcloud-core-libs]: https://io.cira.colostate.edu/s/Tb5fraZDsAeeRX8
[wiki-oneapi]: https://bear.cira.colostate.edu/groups/CloudSat-DPC/-/wikis/Intel-OneAPI/1.-Installation
[slow-intel-fix]: https://community.intel.com/t5/Intel-oneAPI-HPC-Toolkit/slow-execution-of-ifort-icpc-on-MacOSX-catalina/m-p/1292633/highlight/true#M8487
