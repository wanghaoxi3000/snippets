FROM alpine:3

ENV LANG=en_US.UTF-8

COPY clash-linux-amd64-2023.01.29 /usr/bin/clash
COPY config/config.yaml /etc/clash/config/config.yaml
COPY config/ui /etc/clash/config/ui
COPY config/Country.mmdb /etc/clash/config/Country.mmdb
COPY config/ruleset /etc/clash/config/ruleset
COPY entrypoint.sh /root/entrypoint.sh

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk add --no-cache tzdata ca-certificates bash iptables iproute2 libcap \
  && cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del tzdata \
  && adduser --disabled-password --home "$(pwd)" -G root --no-create-home --uid 1086 clash \
  && chown clash -R  /etc/clash/ \
  && chmod +x /root/entrypoint.sh

CMD ["/root/entrypoint.sh", "start"]
