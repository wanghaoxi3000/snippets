#!/usr/bin/env bash

set -ex

start_clash() {
  setcap 'cap_net_admin,cap_net_bind_service=+ep' /usr/bin/clash
  su - clash -c "clash -d /etc/clash/config/"
}

start_iptables() {
  # ROUTE RULES
  ip rule add fwmark 0x162 lookup 0x162
  ip route add local 0.0.0.0/0 dev lo table 0x162

  # clash 链负责处理转发流量
  iptables -t mangle -N clash
  iptables -t mangle -F clash

  # 目标地址为局域网或保留地址的流量跳过处理
  # 保留地址参考: https://zh.wikipedia.org/wiki/%E5%B7%B2%E5%88%86%E9%85%8D%E7%9A%84/8_IPv4%E5%9C%B0%E5%9D%80%E5%9D%97%E5%88%97%E8%A1%A8
  iptables -t mangle -A clash -d 0.0.0.0/8 -j RETURN
  iptables -t mangle -A clash -d 10.0.0.0/8 -j RETURN
  iptables -t mangle -A clash -d 127.0.0.0/8 -j RETURN
  iptables -t mangle -A clash -d 172.16.0.0/12 -j RETURN
  iptables -t mangle -A clash -d 169.254.0.0/16 -j RETURN
  iptables -t mangle -A clash -d 192.168.0.0/16 -j RETURN
  iptables -t mangle -A clash -d 224.0.0.0/4 -j RETURN
  iptables -t mangle -A clash -d 240.0.0.0/4 -j RETURN

  # 其他所有流量转向到 7891 端口，并打上 mark
  iptables -t mangle -A clash -p tcp -j TPROXY --on-port 7891 --tproxy-mark 0x162
  iptables -t mangle -A clash -p udp -j TPROXY --on-port 7891 --tproxy-mark 0x162

  # 最后让所有流量通过 clash 链进行处理
  iptables -t mangle -A PREROUTING -j clash

  # clash_local 链负责处理网关本身发出的流量
  iptables -t mangle -N clash_local

  # 跳过内网流量
  iptables -t mangle -A clash_local -d 0.0.0.0/8 -j RETURN
  iptables -t mangle -A clash_local -d 10.0.0.0/8 -j RETURN
  iptables -t mangle -A clash_local -d 127.0.0.0/8 -j RETURN
  iptables -t mangle -A clash_local -d 172.16.0.0/12 -j RETURN
  iptables -t mangle -A clash_local -d 169.254.0.0/16 -j RETURN
  iptables -t mangle -A clash_local -d 192.168.0.0/16 -j RETURN
  iptables -t mangle -A clash_local -d 224.0.0.0/4 -j RETURN
  iptables -t mangle -A clash_local -d 240.0.0.0/4 -j RETURN

  # 为本机发出的流量打 mark
  iptables -t mangle -A clash_local -p tcp -j MARK --set-mark 0x162
  iptables -t mangle -A clash_local -p udp -j MARK --set-mark 0x162

  # 跳过 clash 程序本身发出的流量, 防止死循环(clash 程序需要使用 "clash" 用户启动)
  iptables -t mangle -A OUTPUT -p tcp -m owner --uid-owner clash -j RETURN
  iptables -t mangle -A OUTPUT -p udp -m owner --uid-owner clash -j RETURN

  # 让本机发出的流量跳转到 CLASH_LOCAL
  # CLASH_LOCAL 链会为本机流量打 mark, 打过 mark 的流量会重新回到 PREROUTING 上
  iptables -t mangle -A OUTPUT -j clash_local

  # 修复 ICMP(ping)
  # 这并不能保证 ping 结果有效(clash 等不支持转发 ICMP), 只是让它有返回结果而已
  # --to-destination 设置为一个可达的地址即可
  # sysctl net.ipv4.conf.all.route_localnet=1
  # iptables -t nat -A PREROUTING -p icmp -d 198.18.0.0/16 -j DNAT --to-destination 127.0.0.1

  # DNS
  # iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53

  # iptables -t nat -N CLASH_DNS_LOCAL
  # iptables -t nat -N CLASH_DNS_EXTERNAL
  # iptables -t nat -F CLASH_DNS_LOCAL
  # iptables -t nat -F CLASH_DNS_EXTERNAL

  # iptables -t nat -A CLASH_DNS_LOCAL -p udp --dport 53 -j REDIRECT --to-ports 1053
  # iptables -t nat -A CLASH_DNS_LOCAL -p tcp --dport 53 -j REDIRECT --to-ports 1053
  # iptables -t nat -A CLASH_DNS_LOCAL -m owner --uid-owner clash -j RETURN

  # iptables -t nat -A CLASH_DNS_EXTERNAL -p udp --dport 53 -j REDIRECT --to-ports 1053
  # iptables -t nat -A CLASH_DNS_EXTERNAL -p tcp --dport 53 -j REDIRECT --to-ports 1053

  # iptables -t nat -I OUTPUT -p udp -j CLASH_DNS_LOCAL
  # iptables -t nat -I PREROUTING -p udp -j CLASH_DNS_EXTERNAL
}

stop_iptables() {
  ip rule del fwmark 0x162 table 0x162 || true
  ip route del local 0.0.0.0/0 dev lo table 0x162 || true

  # iptables -t nat -F
  # iptables -t nat -X
  iptables -t mangle -F
  iptables -t mangle -X clash || true
  iptables -t mangle -X clash_local || true
}

set_router() {
  sleep 1

  # 等待,直到SOCKS端口被监听, 或者clash启动失败
  echo "wait clash ready..."
  while :
  do
    PID=`ps -def | grep -v 'grep' | grep 'clash -d' | awk '{print $1}'` || true
    PORT_EXIST=`ss -tlnp | awk '{print $4}' | grep -E ".*:7890" | head -n 1` || true
    if [ "$PID" == "" ] || [ "$PORT_EXIST" == "" ]; then
      EXPID_EXIST=$(ps aux | awk '{print $4}'| grep 'clash') || true
      if [ ! $EXPID_EXIST ];then
        echo "clash is not running"
        exit 1
      fi
      sleep 1
      continue
    fi

    echo $PID > /var/clash.pid
    break
  done

  echo "clash is ready"

  start_iptables
}

start() {
    echo "start ..."
    stop_iptables
    set_router &
    start_clash
    echo "start end"
}

stop() {
    echo "stop ..."
    stop_iptables
    echo "stop end"
}

main() {
    if [ $# -eq 0 ]; then
        echo "usage: $0 start|stop ..."
        return 1
    fi

    for funcname in "$@"; do
        if [ "$(type -t $funcname)" != 'function' ]; then
            echo "'$funcname' not a shell function"
            return 1
        fi
    done

    for funcname in "$@"; do
        $funcname
    done
    return 0
}

main "$@"