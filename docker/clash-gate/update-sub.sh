#!/usr/bin/env bash
# 订阅更新: 拉取配置, 校验通过后安装并按需热重载
# 用法: update-sub.sh direct|proxy
#   direct 启动前使用, 直连下载, 安装后不重载 (clash 尚未运行)
#   proxy  运行期使用, 通过本地代理下载, 安装后热重载

set -euo pipefail

CONFIG=/etc/clash/config/config.yaml
TMP=/tmp/config.yaml.new
MODE="${1:-proxy}"
CONTROLLER="${CONTROLLER:-http://127.0.0.1:9090}"

# 代理模式经本地 clash 下载
PROXY_OPT=()
if [ "$MODE" = "proxy" ]; then
  PROXY_OPT=(-x "http://127.0.0.1:7890")
fi

if ! curl -fsS --connect-timeout 10 --retry 1 --retry-all-errors -o "$TMP" "${PROXY_OPT[@]}" "$SUB_URL"; then
  echo "[sub] download failed (${MODE})"
  rm -f "$TMP"
  exit 1
fi

if ! clash -t -d /etc/clash/config -f "$TMP" >/dev/null 2>&1; then
  echo "[sub] validation failed, keeping current config"
  rm -f "$TMP"
  exit 1
fi

if cmp -s "$TMP" "$CONFIG"; then
  echo "[sub] no change"
  rm -f "$TMP"
  exit 0
fi

# 重定向写入以覆盖 bind mount 挂载点, cp 会因 File exists 失败
cat "$TMP" > "$CONFIG"
rm -f "$TMP"

if [ "$MODE" = "direct" ]; then
  echo "[sub] config installed, effective on start"
  exit 0
fi

# 等待 controller 就绪后再触发重载
for _ in $(seq 1 10); do
  curl -sf "${CONTROLLER}/version" >/dev/null 2>&1 && break
  sleep 1
done

# 重载, 失败后重试 (controller 偶发未就绪)
for _ in 1 2 3; do
  if curl -sf -X PUT "${CONTROLLER}/configs?force=true" \
    -H "Content-Type: application/json" \
    -d "{\"path\":\"${CONFIG}\"}" >/dev/null; then
    echo "[sub] config updated and reloaded"
    exit 0
  fi
  sleep 2
done
echo "[sub] config updated but reload failed"
exit 1
