#!/usr/bin/env bash

gcloud auth activate-service-account --key-file <(echo "$GCP_KEY")
gsutil -m acl set -R -a public-read gs://${GCP_BUCKET}
