#!/usr/bin/env bash

set -euo pipefail

mkdir backups >/dev/null 2>&1 || true

printf -- "$BOSH_CA_CERT" >ca_cert

BOSH_CLIENT_SECRET="${BOSH_BBR_PASSWORD}"

pushd backups >/dev/null
echo "Running pre-backup-checks on deployment '${DEPLOYMENT_NAME}'..."
../bbr/bbr deployment -t ${BOSH_DIRECTOR_HOST} \
	-u ${BOSH_BBR_USERNAME} \
	--ca-cert ../ca_cert \
	-d "$DEPLOYMENT_NAME" \
	pre-backup-check

echo "Backing up deployment '${DEPLOYMENT_NAME}'..."
if ! ../bbr/bbr deployment -t ${BOSH_DIRECTOR_HOST} \
	-u ${BOSH_BBR_USERNAME} \
	--ca-cert ../ca_cert \
	-d "$DEPLOYMENT_NAME" \
	backup; then
	echo "Backup failed, cleaning up..."
	../bbr/bbr deployment -t ${BOSH_DIRECTOR_HOST} \
		-u ${BOSH_BBR_USERNAME} \
		--ca-cert ../ca_cert \
		-d "${DEPLOYMENT_NAME}" \
		backup-cleanup
fi

tar -cvf "${DEPLOYMENT_NAME}-backup-$(date -u +%Y%m%d%H%M%S).tar" -- *
