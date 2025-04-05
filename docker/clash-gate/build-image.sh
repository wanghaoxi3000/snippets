#!/usr/bin/env bash

if [ -z $2 ]; then
  echo "Usage: $0 {CLASH_VERSION} {METACUBEXD_VERSION}"
  exit 1
fi

echo "Build clash gate docker image by version: [$1] with metacubexd [$2]"

CLASH_VERSION=$1
METACUBEXD_VERSION=$2

echo "Download clash meta version: ${CLASH_VERSION}"
curl -LO https://github.com/MetaCubeX/mihomo/releases/download/${CLASH_VERSION}/mihomo-linux-amd64-compatible-go120-${CLASH_VERSION}.gz
gzip -d mihomo-linux-amd64-compatible-go120-${CLASH_VERSION}.gz
mv mihomo-linux-amd64-compatible-go120-${CLASH_VERSION} clash-meta

echo "Download metacubexd vesion: ${METACUBEXD_VERSION}"
curl -LO https://github.com/MetaCubeX/metacubexd/releases/download/${METACUBEXD_VERSION}/compressed-dist.tgz
mkdir -p config/ui
tar -xzf compressed-dist.tgz -C config/ui

echo "Build docker image"
docker build -t clash-meta-gate:${CLASH_VERSION} .

