#!/usr/bin/env bash

set -euo pipefail

echo "$JUMPBOX_SSH_KEY" >id_rsa && chmod 600 id_rsa

mkdir backups || true
ssh "${JUMPBOX_USER}"@"${JUMPBOX_HOST}" \
	-i ./id_rsa \
	-o "IdentitiesOnly=true" \
	-o "StrictHostKeyChecking=no" \
	"cd ${BOSH_STATE_FOLDER}; tar czf - /data/bosh-state/" >backups/jumpbox-backup-$(date -u +%Y%m%d%H%M%S).tgz
