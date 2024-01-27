#!/usr/bin/env bash
set -ex

PWD=$(cd "$(dirname "$0")";pwd)

XRAY_CONF_FILE=${PWD}/config.json
CADDY_CONF_PATH=${PWD}/caddy

gen_xray_config(){
  echo "Generate xray server config"

  cat <<EOF > ${XRAY_CONF_FILE}
{
    "log": {
        "loglevel": "info"
    },
    "inbounds": [
        {
            "listen": "${CADDY_CONF_PATH}/xray-grpc.socket,0666",
            "port": 10080,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "grpc",
                "grpcSettings": {
                  "serviceName": "rpcpass"
                }
              }
        }
    ],
    "outbounds": [
        {
            "tag": "direct",
            "protocol": "freedom",
            "settings": {}
        },
        {
            "tag": "blocked",
            "protocol": "blackhole",
            "settings": {}
        }
    ],
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            {
                "type": "field",
                "domain": ["geosite:openai"],
                "outboundTag": "direct"
            },
            {
                "type": "field",
                "ip": [
                    "geoip:cn",
                    "geoip:private"
                ],
                "outboundTag": "blocked"
            }
        ]
    }
}
EOF
}

gen_caddy_config(){
  echo "Generate caddy server config"

  mkdir -p ${CADDY_CONF_PATH}
  cat <<EOF > ${CADDY_CONF_PATH}/Caddyfile
${HOST} {
        log {
                output stdout
                format console
        }

        encode gzip

        tls {
                protocols tls1.2 tls1.3
                ciphers TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
                curves x25519
        }

        @grpc {
                protocol grpc
                path /rpcpass/*
        }

        reverse_proxy @grpc unix//var/caddy/xray-grpc.socket {
                transport http {
                        versions h2c
                }
        }

        reverse_proxy https://bing.com {
                header_up Host {upstream_hostport}
        }
}
EOF
}

gen_xray_config

gen_caddy_config

exec ${PWD}/xray run
