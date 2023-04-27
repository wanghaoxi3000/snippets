# V2RAY-TLS

v2ray + tls 代理

## build docker
```
docker build -t v2ray-tls .
```

## ENV
```
cat <<EOF > .env
HOST=${HOST}
UUID=${UUID}
```

## RUN
```
docker compose up -d
```