#!/usr/bin/env bash

set -eu

fly -t env0 set-pipeline -n \
	-p compile-releases \
	-c pipeline.yml

fly -t env0 check-resource -r compile-releases/concourse-release -f version:1.0.0
fly -t env0 check-resource -r compile-releases/credhub-release -f version:1.0.0
fly -t env0 check-resource -r compile-releases/uaa-release -f version:1
fly -t env0 check-resource -r compile-releases/postgres-release -f version:1
fly -t env0 check-resource -r compile-releases/garden-runc-release -f version:1.0.0
fly -t env0 check-resource -r compile-releases/bbr-sdk-release -f version:1.0.0
fly -t env0 check-resource -r compile-releases/grafana-release -f version:1
fly -t env0 check-resource -r compile-releases/influxdb-release -f version:1
fly -t env0 check-resource -r compile-releases/riemann-release -f version:1
fly -t env0 check-resource -r compile-releases/ubuntu-trusty-stemcell -f version:1
