## Dependencies
- zlib - https://zlib.net/zlib-1.2.11.tar.gz
- szip - https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz
- flex - https://github.com/westes/flex/files/981163/flex-2.6.4.tar.gz
- bison - http://ftp.gnu.org/gnu/bison/bison-3.8.tar.gz

Dependencies are built from source using ifort and dpcpp from OneAPI.

## Notes
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

gctp.lib - Comes from https://github.com/tdanckaert/GCTP
hd421m.lib - HDF4
hdf.lib - HDF4
hdfeos.lib - HDF-EOS2
hm421m.lib - HDF4
libjpeg.lib - JPEG
mfhdf.lib - HDF4
szlib.lib - SZlib
xdr.lib - ???
zlib.lib - Zlib1g
