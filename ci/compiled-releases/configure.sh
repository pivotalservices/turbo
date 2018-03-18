#!/usr/bin/env bash

set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
pipeline="turbo-compile-releases"

fly -t env0 set-pipeline -n \
	-p ${pipeline} \
	-c $(git rev-parse --show-toplevel)/ci/compiled-releases/pipeline.yml

fly -t env0 unpause-pipeline -p ${pipeline}

fly -t env0 check-resource -r ${pipeline}/concourse-release -f version:1.0.0
fly -t env0 check-resource -r ${pipeline}/credhub-release -f version:1.0.0
fly -t env0 check-resource -r ${pipeline}/uaa-release -f version:1
fly -t env0 check-resource -r ${pipeline}/postgres-release -f version:1
fly -t env0 check-resource -r ${pipeline}/garden-runc-release -f version:1.0.0
fly -t env0 check-resource -r ${pipeline}/backup-and-restore-sdk-release -f version:1.0.0
fly -t env0 check-resource -r ${pipeline}/grafana-release -f version:1
fly -t env0 check-resource -r ${pipeline}/influxdb-release -f version:1
fly -t env0 check-resource -r ${pipeline}/riemann-release -f version:1
fly -t env0 check-resource -r ${pipeline}/ubuntu-trusty-stemcell -f version:1
