#!/bin/sh

# Creates a package filename for the given package name and version

PACKAGE=$1
PACKAGE_VERSION=$2

OS=`uname -s | tr '[:upper:]' '[:lower:]'`
if [ "${OS}" = "linux" ]; then
    . /etc/os-release
    DIST=`echo ${ID} | tr '[:upper:]' '[:lower:]'`
    MACH=`uname -m`
elif [ "${OS}" = "darwin" ]; then
    DIST='apple'
    MACH=`uname -m`
fi

echo ${PACKAGE}-${PACKAGE_VERSION}-${DIST}-${OS}-${MACH}.tar.gz
