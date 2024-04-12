FROM alpine:3.14 as builder

ARG YQ_VERSION=v4.29.2
ARG YQ_BINARY=yq_linux_amd64
ARG TASK_VERSION=v3.17.0
ARG TASK_BINARY=task_linux_amd64.tar.gz

RUN apk add -U --no-cache \
    bash \
    ruby

RUN gem install yaml-cv

WORKDIR /opt/app

RUN apk add openssl

RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

RUN wget -O- https://github.com/go-task/task/releases/download/${TASK_VERSION}/${TASK_BINARY} \
    | tar xz -C /usr/bin

COPY . .

FROM builder as build

WORKDIR /opt/app

RUN task build

FROM busybox as release

WORKDIR /opt/app

COPY --from=build /opt/app/build/cv.html cv.html

VOLUME /opt/app

LABEL maintainer="Kirill <krill123321@gmail.com>"
