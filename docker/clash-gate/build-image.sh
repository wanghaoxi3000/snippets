#!/usr/bin/env bash

if [ -z $1 ]; then
  echo "Usage: $0 {CLASH_VERSION}"
  exit 1
fi

echo "Build clash gate docker image by version: $1"

CLASH_VERSION=$1

echo "Download clash meta version: ${CLASH_VERSION}"
curl -LO https://github.com/MetaCubeX/mihomo/releases/download/${CLASH_VERSION}/mihomo-linux-amd64-compatible-go120-${CLASH_VERSION}.gz
gzip -d mihomo-linux-amd64-compatible-go120-${CLASH_VERSION}.gz
mv mihomo-linux-amd64-compatible-go120-${CLASH_VERSION} clash-meta

echo "Build docker image"
docker build -t clash-meta-gate:${CLASH_VERSION} .
