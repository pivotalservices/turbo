#!/usr/bin/env bash

set -eo pipefail

curl -L -s "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" -o jq && chmod 755 jq && mv jq /usr/local/bin

bbr_url=$(curl -s https://api.github.com/repos/cloudfoundry-incubator/bosh-backup-and-restore/releases/latest | jq -r ".assets[] | select(.name | test(\"bbr-\")) | .browser_download_url")

mkdir bbr
curl -L -s -o bbr.tar $bbr_url >/dev/null
tar -xvf bbr.tar >/dev/null
chmod 755 releases/bbr >/dev/null
sudo mv releases/bbr bbr/ >/dev/null
rm -rf bbr.tar releases >/dev/null
echo "bbr download complete"
