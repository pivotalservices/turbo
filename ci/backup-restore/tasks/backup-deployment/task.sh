#!/usr/bin/env bash

set -euo pipefail

mkdir backups >/dev/null 2>&1 || true

echo "$JUMPBOX_SSH_KEY" >id_rsa && chmod 600 id_rsa

# echo "Running pre-backup-checks on deployment '${DEPLOYMENT_NAME}'..."
# ../bbr/bbr deployment -t ${BOSH_DIRECTOR_HOST} \
# 	-u "${BOSH_BBR_USERNAME}" \
# 	-p "${BOSH_BBR_PASSWORD}" \
# 	--ca-cert ../ca_cert \
# 	-d "$DEPLOYMENT_NAME" \
# 	pre-backup-check

# echo "Backing up deployment '${DEPLOYMENT_NAME}'..."
# if ! ../bbr/bbr deployment -t ${BOSH_DIRECTOR_HOST} \
# 	-u "${BOSH_BBR_USERNAME}" \
# 	-p "${BOSH_BBR_PASSWORD}" \
# 	--ca-cert ../ca_cert \
# 	-d "$DEPLOYMENT_NAME" \
# 	backup; then
# 	echo "Backup failed, cleaning up..."
# 	../bbr/bbr deployment -t ${BOSH_DIRECTOR_HOST} \
# 		-u "${BOSH_BBR_USERNAME}" \
# 		-p "${BOSH_BBR_PASSWORD}" \
# 		--ca-cert ../ca_cert \
# 		-d "${DEPLOYMENT_NAME}" \
# 		backup-cleanup
# fi

cleanup() {
	ssh "${JUMPBOX_SSH_USER}"@"${JUMPBOX_HOST}" \
		-i ./id_rsa \
		-o "IdentitiesOnly=true" \
		-o "StrictHostKeyChecking=no" \
		"cd .ci-backups/${DEPLOYMENT_NAME} && rm -rf *"
}

echo "Running pre-backup-checks on deployment '${DEPLOYMENT_NAME}'..."
if ssh "${JUMPBOX_SSH_USER}"@"${JUMPBOX_HOST}" \
	-i ./id_rsa \
	-o "IdentitiesOnly=true" \
	-o "StrictHostKeyChecking=no" \
	"mkdir -p .ci-backups/${DEPLOYMENT_NAME} && \
		cd .ci-backups/${DEPLOYMENT_NAME} && \
		rm -rf * && \
		bbr deployment -t ${BOSH_DIRECTOR_HOST} \
		-u ${BOSH_BBR_USERNAME} \
		-p \"${BOSH_BBR_PASSWORD}\" \
		--ca-cert \"${BOSH_CA_CERT}\" \
		-d \"${DEPLOYMENT_NAME}\" pre-backup-check || exit 1"; then

	echo "Backing up deployment '${DEPLOYMENT_NAME}'..."
	if ssh "${JUMPBOX_SSH_USER}"@"${JUMPBOX_HOST}" \
		-i ./id_rsa \
		-o "IdentitiesOnly=true" \
		-o "StrictHostKeyChecking=no" \
		"cd .ci-backups/${DEPLOYMENT_NAME} && \
			bbr deployment -t ${BOSH_DIRECTOR_HOST} \
			-u ${BOSH_BBR_USERNAME} \
			-p \"${BOSH_BBR_PASSWORD}\" \
			--ca-cert \"${BOSH_CA_CERT}\" \
			-d \"${DEPLOYMENT_NAME}\" backup || exit 1"; then

		echo "Downloading backup for deployment '${DEPLOYMENT_NAME}'..."
		ssh "${JUMPBOX_SSH_USER}"@"${JUMPBOX_HOST}" \
			-i ./id_rsa \
			-o "IdentitiesOnly=true" \
			-o "StrictHostKeyChecking=no" \
			"cd .ci-backups/${DEPLOYMENT_NAME} && \
				tar czf - *" >backups/${DEPLOYMENT_NAME}-backup-$(date -u +%Y%m%d%H%M%S).tgz
		cleanup
	else
		echo "Backup failed... Cleaning up..."
		ssh "${JUMPBOX_SSH_USER}"@"${JUMPBOX_HOST}" \
			-i ./id_rsa \
			-o "IdentitiesOnly=true" \
			-o "StrictHostKeyChecking=no" \
			"cd .ci-backups/${DEPLOYMENT_NAME} && \
				bbr deployment -t ${BOSH_DIRECTOR_HOST} \
				-u ${BOSH_BBR_USERNAME} \
				-p \"${BOSH_BBR_PASSWORD}\" \
				--ca-cert \"${BOSH_CA_CERT}\" \
				-d \"${DEPLOYMENT_NAME}\" backup-cleanup || exit 1"
		cleanup
	fi
else
	echo "pre-backup-check failed, cleaning up..."
	cleanup
	exit 1
fi
