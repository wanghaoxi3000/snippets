#!/usr/bin/env bash
set -ex

CMD=$1

if [ "$CMD" != "tsp" ] && [ "$CMD" != "v2ray" ]
then
    echo "Usage $0 tsp | v2ray"
fi


TSP_CONF_FILE=${TSP_CONF}/config.yaml
V2RAY_CONF_FILE=${V2RAY_CONF}/config.json

tspFun(){
  echo "Start tsp command"

  if [ ! -f ${TSP_CONF_FILE} ]
  then
    cat <<EOF > ${TSP_CONF_FILE}
# listen: 监听地址
listen: 0.0.0.0:443

# redirecthttps: 监听一个地址，发送到这个地址的 http 请求将被重定向到 https
redirecthttps: 0.0.0.0:80

# inboundbuffersize: 入站缓冲区大小，单位 KB, 默认值 4
# 相同吞吐量和连接数情况下，缓冲区越大，消耗的内存越大，消耗 CPU 时间越少。在网络吞吐量较低时，缓存过大可能增加延迟。
inboundbuffersize: 4

# outboundbuffersize: 出站缓冲区大小，单位 KB, 默认值 32
outboundbuffersize: 32

# vhosts: 按照按照 tls sni 扩展划分为多个虚拟 host
vhosts:
  - name: ${HOST}
    # tlsoffloading: 解开 tls, true 为解开，解开后可以识别 http 流量，适用于 vmess over tls 和 http over tls (https) 分流等
    tlsoffloading: true
    managedcert: true
    # keytype: 启用 managedcert 时，生成的密钥对类型，支持的选项 ed25519、p256、p384、rsa2048、rsa4096、rsa8192
    keytype: p256
    # alpn: ALPN, 多个 next protocol 之间用 "," 分隔
    alpn: h2,http/1.1
    # protocols: 指定 tls 协议版本，格式为 min,max , 可用值 tls12(默认最小), tls13(默认最大)
    # 如果最小值和最大值相同，那么你只需要写一次
    # tls12 仅支持 FS 且 AEAD 的加密套件
    protocols: tls13

    http:
      handler: fileServer
      args: /var/html/template

    default:
      handler: proxyPass
      args: ${V2RAY}:40001
EOF
  fi

  tls-shunt-proxy -config ${TSP_CONF}/config.yaml
}

v2rayFun(){
  echo "Start v2ray command"

  if [ ! -f ${V2RAY_CONF_FILE} ]
  then
    cat <<EOF > ${V2RAY_CONF_FILE}
{
  "log": {
    "loglevel": "info"
  },
  "inbounds": [{
    "port": 40001,
    "protocol": "vmess",
    "settings": {
      "clients": [{ "id": "${UUID}" }]
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
EOF
  fi

  v2ray -c ${V2RAY_CONF_FILE}
}

if [ "$CMD" == "tsp" ]
then
    tspFun
fi

if [ "$CMD" == "v2ray" ]
then
    v2rayFun
fi
