#!/usr/bin/env bash

set -euo pipefail

mkdir backups >/dev/null 2>&1 || true

printf -- "$BOSH_SSH_KEY" >id_rsa
chmod 600 id_rsa

pushd backups
echo "Running pre-backup-checks on director..."
../bbr/bbr director --private-key-path ./id_rsa \
	--username "$BOSH_SSH_USER" \
	--host "$BOSH_DIRECTOR_HOST" \
	pre-backup-check

echo "Backing up director '$BOSH_DIRECTOR_HOST'..."
if ! ../bbr/bbr director --private-key-path ./id_rsa \
	--username "$BOSH_SSH_USER" \
	--host "$BOSH_DIRECTOR_HOST" \
	backup; then
	echo "Backup failed, cleaning up..."
	../bbr/bbr director --private-key-path ./id_rsa \
		--username "$BOSH_SSH_USER" \
		--host "$BOSH_DIRECTOR_HOST" \
		backup-cleanup
fi

tar -cvf director-backup-$(date -u +%Y%m%d%H%M%S).tar -- *
