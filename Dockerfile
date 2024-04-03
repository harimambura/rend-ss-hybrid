FROM golang:alpine
WORKDIR /usr/local/bin
RUN apk update && apk add wget
RUN apk add nginx
RUN apk add unzip
RUN go install github.com/shadowsocks/go-shadowsocks2@latest

COPY conf/ /conf
COPY entrypoint.sh .
RUN chmod +x /usr/local/bin/entrypoint.sh
ENV PATH="$GOPATH/bin:/:$PATH"
ENTRYPOINT ["sh", "entrypoint.sh"]