#!/usr/bin/env bash

mkdir -p ./packages
PACK_VER=`git describe --tags`

# NOTE: This currently invalidates the cache every time it is run due to the use of PACK_VER.
#       To avoid cache invalidation, I think I'll need to insert the package version AFTER the tar file has been created

# # CentOS
# docker build . --target export --build-arg PACK_VER=${PACK_VER} -t core-libs-package_centos-8:latest -f Dockerfile.centos-8 -o ./packages

# Debian
docker build . --target export --build-arg PACK_VER=${PACK_VER} -t core_libs_package_debian-10:latest -f Dockerfile.debian-10 -o ./packages

# OSX
make package
