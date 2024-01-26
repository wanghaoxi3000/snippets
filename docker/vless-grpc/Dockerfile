FROM debian:12

ARG XRAY_VERSION=v1.8.7

ENV TZ=Asia/Shanghai

WORKDIR /opt/xray

COPY entrypoint.sh /opt/xray

RUN apt-get update \
  && apt-get install -y locales curl unzip \
  && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
  && DOWNLOAD_URL="https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" \
  && echo "DOWNLOAD_URL: $DOWNLOAD_URL" \
  && curl -LO -H "Cache-Control: no-cache" "${DOWNLOAD_URL}" \
  && unzip "Xray-linux-64.zip" \
  && rm -r Xray-linux-64.zip \
  && chmod +x entrypoint.sh

CMD [ "/opt/xray/entrypoint.sh" ]
