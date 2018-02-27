#!/usr/bin/env bash
set -x

sudo apt-get update || exit 1
sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 jq || exit 1

curl -L --output bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.48-linux-amd64 || exit 1
chmod +x bosh || exit 1
sudo mv bosh /usr/local/bin || exit 1

credhub_url=$(curl -s https://api.github.com/repos/cloudfoundry-incubator/credhub-cli/releases/latest | jq -r ".assets[] | select(.name | test(\"credhub-linux\")) | .browser_download_url")
(curl -L -o credhub.tgz $credhub_url && \
tar -zxvf credhub.tgz
chmod 755 credhub && \
sudo mv credhub /usr/local/bin/ && \
rm -rf credhub.tgz && \
echo "credhub installation complete") || exit 1
