#!/usr/bin/env bash

set -e
set -x

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

if [ -z ${PREFIX} ]; then
    echo "Environment variable 'PREFIX' must be set"
fi

if [[ -z INTEL_PATH ]]; then
    INTEL_PATH=/opt/intel
fi

SRCFILE=$(realpath $1)
TEMPDIR=${PWD}/tmp

if [ -d "${TEMPDIR}" ]; then
    rmdir ${TEMPDIR}
fi
mkdir -p ${TEMPDIR}

set +e
source ${INTEL_PATH}/oneapi/setvars.sh
sv_ret=$?
set -e
if [[ "${sv_ret}" == "3" ]]; then
    echo "Intel environment already set"
elif [[ "${sv_ret}" != "0" ]]; then
    echo "Error encountered in /opt/intel/oneapi/setvars.sh"
    exit ${sv_ret}
fi

echo $?

cd ${TEMPDIR}
tar -xzvf "${SRCFILE}" --directory "${TEMPDIR}" --strip-components=1

./configure --prefix=$(realpath ${PREFIX}) ${CONFIGFLAGS}
make
make install

# This was intended for use when only building the parts of these packages that are needed
# make ${SPECIAL_TARGET}
# if [[ -z $SPECIAL_TARGET ]]; then
#     make install
# else
#     mkdir -p ./build/$(dirname ${SPECIAL_TARGET})
#     cp ${SPECIAL_TARGET} ./build/${SPECIAL_TARGET}
# fi

cd ..
rm -rf ${TEMPDIR}
