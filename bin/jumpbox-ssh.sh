#!/usr/bin/env bash

TERRAFORM_OUTPUT=$(terraform output --json | jq 'map_values(.value)')

IDRSA=$(mktemp)
terraform output --json | jq -r '.jumpbox_ssh_private_key.value' >${IDRSA}
ssh ubuntu@$(echo "$TERRAFORM_OUTPUT" | jq -r '.jumpbox_ip') \
	-i "${IDRSA}" \
	-o "IdentitiesOnly=true" "$@"

rm -rf ${IDRSA}
