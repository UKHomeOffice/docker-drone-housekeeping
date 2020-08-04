FROM alpine:3.12

ARG DRONE_CLI_VERSION=v1.2.1

RUN apk add --no-cache bash curl && \
    cd $HOME && \
    (curl -L https://github.com/drone/drone-cli/releases/download/${DRONE_CLI_VERSION}/drone_linux_amd64.tar.gz | tar zx ) && \
    mv drone /usr/local/bin

COPY scripts /scripts

RUN chmod +x /scripts/drone-housekeeping.sh

WORKDIR /scripts

USER 1000

CMD "/scripts/drone-housekeeping.sh"