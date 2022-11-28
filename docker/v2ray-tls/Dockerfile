FROM debian:11

ARG V2RAY_VERSION=v4.45.2

ENV TZ=Asia/Shanghai
ENV TSP_CONF=/etc/tsp
ENV V2RAY_CONF=/etc/v2ray

RUN apt-get update \
  && apt-get install -y locales curl unzip \
  && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
  && API_URL="https://api.github.com/repos/liberal-boy/tls-shunt-proxy/releases/latest" \
  && VSRC_ROOT='/tmp/download' \
  && DOWNLOAD_PATH="${VSRC_ROOT}/tls-shunt-proxy.zip" \
  && DOWNLOAD_URL="$(curl -H "Accept: application/json" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0" -s "${API_URL}" --connect-timeout 10| grep 'browser_download_url' | cut -d\" -f4)" \
  && echo "DOWNLOAD_URL: $DOWNLOAD_URL" \
  && mkdir -p "${VSRC_ROOT}" \
  && curl -L -H "Cache-Control: no-cache" -o "${DOWNLOAD_PATH}" "${DOWNLOAD_URL}" \
  && unzip -o -d /usr/local/bin/ "${DOWNLOAD_PATH}" \
  && chmod +x /usr/local/bin/tls-shunt-proxy \
  && mkdir -p ${TSP_CONF} \
  && V2RAY_URL="https://github.com/v2fly/v2ray-core/releases/download/${V2RAY_VERSION}/v2ray-linux-64.zip" && echo "V2RAY_URL: $V2RAY_URL" \
  && curl -L -H "Cache-Control: no-cache" -o "${VSRC_ROOT}/v2ray-linux-64.zip" "${V2RAY_URL}" \
  && unzip -o -d "${VSRC_ROOT}/v2ray" "${VSRC_ROOT}/v2ray-linux-64.zip" \
  && mv "${VSRC_ROOT}/v2ray/v2ray" /usr/local/bin/ && mv "${VSRC_ROOT}/v2ray/v2ctl" /usr/local/bin/ \
  && mkdir -p ${V2RAY_CONF} && cp -r ${VSRC_ROOT}/v2ray/geo* /etc/v2ray/ \
  && rm -r "${VSRC_ROOT}"

COPY template /var/html
COPY entrypoint.sh /root

RUN chmod +x /root/entrypoint.sh

ENTRYPOINT [ "/root/entrypoint.sh" ]