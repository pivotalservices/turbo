#!/usr/bin/env bash
export BOSH_HOST="https://$(bosh int "$BOSH_VAR_CACHE" --path /bosh_target)"
export BOSH_CLIENT_SECRET=$(bosh int "$BOSH_VAR_CACHE" --path /bosh_client_secret)
export BOSH_CA_CERT="$BOSH_STATE_FOLDER/ca.pem"

bbr deployment -t ${BOSH_HOST} \
	-u ${BOSH_CLIENT} \
	--ca-cert ${BOSH_CA_CERT} \
	-d ${ENV_NAME}-ucc backup
