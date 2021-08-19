FROM golang:1.16-alpine AS base

WORKDIR /
RUN mkdir -p ./likechain
COPY ./go.mod ./likechain/go.mod
COPY ./go.sum ./likechain/go.sum
WORKDIR /likechain
RUN go mod download


FROM base as builder
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3
RUN apk add --no-cache $PACKAGES
WORKDIR /likechain
COPY . .
ARG VERSION="fotan-1"
ARG COMMIT=""
RUN go build \
-ldflags "\
-X \"github.com/cosmos/cosmos-sdk/version.Name=likecoin-chain\" \
-X \"github.com/cosmos/cosmos-sdk/version.AppName=liked\" \
-X \"github.com/cosmos/cosmos-sdk/version.BuildTags=netgo ledger\" \
-X \"github.com/cosmos/cosmos-sdk/version.Version=${VERSION}\" \
-X \"github.com/cosmos/cosmos-sdk/version.Commit=${COMMIT}\" \
" \
-tags "netgo ledger" \
-o /go/bin/liked cmd/liked/main.go


FROM alpine:3.5
ARG password
RUN apk --update add --no-cache openssh bash supervisor ca-certificates curl \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:$password" | chpasswd \
  && rm -rf /var/cache/apk/*
RUN sed -ie 's/#Port 22/Port 2242/g' /etc/ssh/sshd_config
RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 2242 22656 26657
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --from=builder /go/bin/liked /usr/bin/liked
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
