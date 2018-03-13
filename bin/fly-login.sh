#!/usr/bin/env bash

TERRAFORM_OUTPUT=$(terraform output --json | jq 'map_values(.value)')

ENVIRONMENT_NAME="$(echo "$TERRAFORM_OUTPUT" | jq -r '.environment_name')"
CONCOURSE_URL="$(echo "$TERRAFORM_OUTPUT" | jq -r '.concourse_url')"

fly -t "$ENVIRONMENT_NAME" login -c "$CONCOURSE_URL" -k \
	-u admin -p "$(echo "$TERRAFORM_OUTPUT" | jq -r '.concourse_password')" >/dev/null || exit 1

fly -t "$ENVIRONMENT_NAME" sync || exit 1

echo "You are now connected to concourse on '$CONCOURSE_URL' as user 'admin'"
echo "You can use: fly -t \"$ENVIRONMENT_NAME\" your-command"
