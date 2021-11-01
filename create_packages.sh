#!/usr/bin/env bash

mkdir -p ./packages

# CentOS
docker build . --target export -t core-libs-package_centos-8:latest -f Dockerfile.centos-8 -o ./packages

# Debian
docker build . --target export -t core_libs_package_debian-10:latest -f Dockerfile.debian-10 -o ./packages

# OSX
make package
