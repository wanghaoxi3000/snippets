# CLASH-GATE

clash meta 网关


## Build docker
```
bash build-image.sh ${CLASH_VERSION} ${METACUBEXD_VERSION}
```

## RUN
在当前目录创建自定义配置 router.yaml

```
docker run --name clash-gate -td --network clash -v $(pwd)/router.yaml:/etc/clash/config/config.yaml --cap-add=NET_ADMIN clash-meta-gate:${CLASH_VERSION}
```

## 环境变量

| 变量 | 说明 | 默认 |
|---|---|---|
| `SUB_URL` | 订阅地址, 设置后容器启动时直连拉取一次 | 空, 不启用订阅 |
| `SUB_CRON` | 订阅更新 cron 表达式, 仅在 `SUB_URL` 已设置时生效 | 空, 不启用定时更新 |
| `CONTROLLER` | update-sub.sh 热重载访问的控制器地址, 须与 router.yaml 的 external-controller 一致 | `http://127.0.0.1:9090` |

`router.yaml` 的 `external-controller` 绑定非 `127.0.0.1` 地址时必须同时设置 `CONTROLLER`, 否则热重载失败。

完整启动示例:

```
docker run --name clash-gate -td --network clash \
  -e SUB_URL='https://example.com/config.yaml?token=<token>' \
  -e SUB_CRON='0 4 * * *' \
  -e CONTROLLER='http://192.168.50.2:9090' \
  -v $(pwd)/router.yaml:/etc/clash/config/config.yaml \
  --cap-add=NET_ADMIN \
  clash-meta-gate:${CLASH_VERSION}
```

## 本机连接
```
ip link add clash-shim link eth0 type macvlan mode bridge
ip addr add 192.168.50.3 dev clash-shim
ip link set clash-shim up
ip route add 192.168.50.2 dev clash-shim
```

## 参考链接
- https://jiajunhuang.com/articles/2022_11_20-router.md.html
- https://zhuanlan.zhihu.com/p/563311580
- https://haoyu.love/blog1412.html
