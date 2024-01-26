# CLASH-GATE

clash meta 网关

## 下载 clash-meta
```
CLASH_VERSION=v1.18.0

curl -LO https://github.com/MetaCubeX/mihomo/releases/download/${CLASH_VERSION}/mihomo-linux-amd64-compatible-go120-${CLASH_VERSION}.gz
gzip -d mihomo-linux-amd64-compatible-go120-${CLASH_VERSION}.gz
```

## build docker
```
docker build -t clash-meta-gate:${CLASH_VERSION}
```

## RUN
在当前目录创建自定义配置 router.yaml

```
docker run --name clash-gate -td --network clash -v $(pwd)/router.yaml:/etc/clash/config/config.yaml --cap-add=NET_ADMIN clash-meta-gate:${CLASH_VERSION}
```

## 本机连接
```
ip link add clash-shim link eth0 type macvlan mode bridge
ip addr add 192.168.50.3 dev clash-shim
ip link set clash-shim up
ip route add 192.168.50.2 dev clash-shim
```