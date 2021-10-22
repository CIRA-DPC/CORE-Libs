#!/usr/bin/env bash

set -e
set -x

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

if [ -z ${PREFIX} ]; then
    echo "Environment variable 'PREFIX' must be set"
fi

SRCFILE=$(realpath $1)
TMPDIR=${PWD}/tmp

if [ -d "${TMPDIR}" ]; then
    rmdir ${TMPDIR}
fi
mkdir -p ${TMPDIR}

set +e
source /opt/intel/oneapi/setvars.sh
sv_ret=$?
set -e
if [[ "${sv_ret}" != "0" ]]; then
    echo "Error encountered in /opt/intel/oneapi/setvars.sh"
    exit ${sv_ret}
fi

echo $?

cd ${TMPDIR}
tar -xzvf "${SRCFILE}" --directory "${TMPDIR}" --strip-components=1

./configure --prefix=$(realpath ${PREFIX}) ${CONFIGFLAGS}
make
make install

cd ..
rm -rf ${TMPDIR}
