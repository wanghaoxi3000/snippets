# CLASH-GATE

clash 网关

## 下载 clash-premium
```
curl -LO https://release.dreamacro.workers.dev/2023.01.29/clash-linux-amd64-2023.01.29.gz
gzip -d clash-linux-amd64-2023.01.29.gz
```

## build docker
```
docker build -t clash-gate:2023.01.29
```

## RUN
```
docker run --name clash-gate -td --network clash -v $(pwd)/config/router.yaml:/etc/clash/config/config.yaml --cap-add=NET_ADMIN clash-gate:alpine-2023.01.29
```

## 本机连接
```
ip link add clash-shim link eth0 type macvlan mode bridge
ip addr add 192.168.50.3 dev clash-shim
ip link set clash-shim up
ip route add 192.168.50.2 dev clash-shim
```