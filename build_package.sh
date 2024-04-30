#!/usr/bin/env bash

set -e
set -x

echo "In build_package.sh"

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

if [ -z ${PREFIX} ]; then
    echo "Environment variable 'PREFIX' must be set"
    exit 1
fi

SRCFILE=$(realpath $1)
TEMPDIR=${PWD}/tmp

echo "Before TEMPDIR"
if [ -d "${TEMPDIR}" ]; then
    rm -rf ${TEMPDIR}
fi
mkdir -p ${TEMPDIR}

# if [[ "${COMPILER_SET}" == "intel" ]]; then
#     if [ -z ${ONEAPI_PATH} ]; then
#         ONEAPI_PATH=/opt/intel/oneapi
#     fi
#     set +e
#     source ${ONEAPI_PATH}/setvars.sh
#     sv_ret=$?
#     set -e
#     if [[ "${sv_ret}" == "3" ]]; then
#         echo "Intel environment already set"
#     elif [[ "${sv_ret}" != "0" ]]; then
#         echo "Error encountered in /opt/intel/oneapi/setvars.sh"
#         exit ${sv_ret}
#     fi
# fi

echo $?

echo "Before tar"
cd ${TEMPDIR}
tar -xzvf "${SRCFILE}" --directory "${TEMPDIR}" --strip-components=1

echo "**********************************************************"
env
echo "**********************************************************"

echo "Before configure"
./configure --prefix=$(realpath ${PREFIX}) ${CONFIGFLAGS}
make
make install

cd ..
rm -rf ${TEMPDIR}
