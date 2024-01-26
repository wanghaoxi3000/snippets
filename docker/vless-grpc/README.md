## VLESS-GRPC

vless + grpc proxy

## build docker
```
docker build -t xray-server .
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