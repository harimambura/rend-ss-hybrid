FROM golang:alpine

RUN apt update && apt add wget

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV PATH="$GOPATH/bin:/:$PATH"
CMD /entrypoint.sh
