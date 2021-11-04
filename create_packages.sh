#!/usr/bin/env bash

mkdir -p ./packages
PACK_VER=`git describe --tags`

# CentOS
docker build . --target export --build-arg PACK_VER=${PACK_VER} -t core-libs-package_centos-8:latest -f Dockerfile.centos-8 -o ./packages

# Debian
docker build . --target export --build-arg PACK_VER=${PACK_VER} -t core_libs_package_debian-10:latest -f Dockerfile.debian-10 -o ./packages

# OSX
make package
