#!/usr/bin/env bash

TERRAFORM_OUTPUT=$(terraform output --json | jq 'map_values(.value)')

CREDHUB_SERVER=$(echo "$TERRAFORM_OUTPUT" | jq -r '.credhub_url')
CREDHUB_CLIENT=credhub-admin
CREDHUB_SECRET=$(echo "$TERRAFORM_OUTPUT" | jq -r '.credhub_password')

credhub api -s "$CREDHUB_SERVER" --skip-tls-validation >/dev/null || exit 1
credhub login --client-name "$CREDHUB_CLIENT" --client-secret "$CREDHUB_SECRET" --skip-tls-validation >/dev/null || exit 1
echo "You're now connected to credhub on '$CREDHUB_SERVER' as user '$CREDHUB_CLIENT'"
