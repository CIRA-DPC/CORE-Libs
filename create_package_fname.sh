#!/bin/sh

PACKAGE=$1

OS=`uname -s | tr '[:upper:]' '[:lower:]'`
if [ "${OS}" = "linux" ]; then
    . /etc/os-release
    DIST=`echo ${ID} | tr '[:upper:]' '[:lower:]'`
    MACH=`uname -m`
elif [ "${OS}" = "darwin" ]; then
    DIST='apple'
    MACH=`uname -m`
fi

TAG=`git describe --tags`

echo ${PACKAGE}-${TAG}-${DIST}-${OS}-${MACH}.tar.gz