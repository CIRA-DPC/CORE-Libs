#!/bin/sh

cat ./build-pipeline-stub.yml

# This is just used for testing purposes since CI_REGISTRY_IMAGE is always set in gitlab-ci
if [ -z "${CI_REGISTRY_IMAGE}" ]; then
    CI_REGISTRY_IMAGE=bear.cira.colostate.edu:4567/cloudsat-dpc/cloudsat/algorithms/core_libs
fi

dockerfiles=$(ls Dockerfile*)
for df in $dockerfiles; do
    df_suff=$(echo $df | sed -ne 's,Dockerfile\.\(.*\),\1,p')
    if [ -z "${df_suff}" ]; then
        OUTPUT_IMAGE=$CI_REGISTRY_IMAGE
    else
        OUTPUT_IMAGE=$CI_REGISTRY_IMAGE/$df_suff
    fi
    cat <<EOF

Build-${df}:
  extends: .Build-Docker-Image
  variables:
    DOCKERFILE: ${df}
    OUTPUT_IMAGE: $OUTPUT_IMAGE

Push-${df}:
  extends: .Push-Docker-Image
  variables:
    DOCKERFILE: ${df}
    OUTPUT_IMAGE: $OUTPUT_IMAGE
EOF
done
