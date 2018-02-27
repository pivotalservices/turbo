#!/usr/bin/env bash

DEPLOYMENT="concourse"
DEPLOYMENT_HOME="/home/${tf_ssh_user}/automation/$DEPLOYMENT"

DEPLOYMENT_FLAGS=${tf_flags}

DEPLOYMENT_VAR_STORE="$DEPLOYMENT_HOME/state/creds.yml"
