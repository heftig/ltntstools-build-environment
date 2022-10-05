ARG version=v1.16.0

FROM ubuntu:20.04 AS builder
ARG version

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get full-upgrade -y && apt-get install -y \
    build-essential git automake libtool pkg-config tcl cmake nasm \
    libz-dev libncurses-dev libpcap-dev liblzma-dev libbz2-dev libzen-dev \
    librdkafka-dev libssl-dev

# Force linking with static library
RUN rm /usr/lib/x86_64-linux-gnu/lib{pcap,crypto,lzma,bz2}.so

ADD . /build/
RUN cd build && ./build.sh ${version} && \
    strip --strip-unneeded target-root/usr/bin/tstools_util

FROM ubuntu:20.04
ARG version

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get full-upgrade -y && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target-root/usr/bin/tstools_util /usr/local/bin/
RUN cd /usr/local/bin && ./tstools_util --symlinks

LABEL name "ltntstools ${version}"
LABEL vendor "LTN Global Communications, Inc."
