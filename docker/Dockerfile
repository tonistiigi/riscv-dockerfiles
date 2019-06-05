
# docker build --platform=linux/riscv64 -t tonistiigi/docker:riscv .
# docker run -it --privileged tonistiigi/docker:riscv

FROM tonistiigi/xx:riscv-toolchain AS riscv-gnu
RUN apt-get update && apt-get install -y git autoconf libtool make curl bzip2 ca-certificates

FROM riscv-gnu AS libseccomp
WORKDIR /src
RUN git clone git://github.com/seccomp/libseccomp && cd libseccomp && \
  git fetch origin pull/134/head && \
  git checkout FETCH_HEAD
WORKDIR /src/libseccomp
RUN autoreconf -fis && \
  ./configure --host=riscv64-linux --prefix=/usr/riscv64-linux-gnu/riscv64-buildroot-linux-gnu/sysroot/usr/ && \
  make && make install && \
  mkdir /out && \
  cp -a /usr/riscv64-linux-gnu/riscv64-buildroot-linux-gnu/sysroot/usr/lib/libseccomp* /out/

FROM libseccomp AS crun
RUN apt-get install -y pkg-config python3 go-md2man
RUN apt-get install -y libcap-dev:riscv64 libyajl-dev:riscv64
COPY crun.diff /tmp/
WORKDIR /src
RUN git clone git://github.com/giuseppe/crun && cd crun && \
  git checkout 1c9ffac294f232a630d38d988353736f0fd42408 && \
  git apply /tmp/crun.diff
WORKDIR /src/crun
# yuck
RUN ./autogen.sh && \
  ln -s /usr/include/yajl /usr/riscv64-linux-gnu/riscv64-buildroot-linux-gnu/sysroot/usr/include/yajl && \
  ln -s /usr/include/sys/capability.h /usr/riscv64-linux-gnu/riscv64-buildroot-linux-gnu/sysroot/usr/include/sys/capability.h && \
  PKG_CONFIG_PATH=/usr/lib/riscv64-linux-gnu/pkgconfig LDFLAGS="-L/usr/lib/riscv64-linux-gnu" ./configure --host=riscv64-linux && \
  make

FROM --platform=$BUILDPLATFORM alpine AS runc
RUN mkdir /out && cd out && ln -s crun runc

FROM --platform=$BUILDPLATFORM tonistiigi/xx:golang-riscv AS docker
RUN apk add --no-cache coreutils
RUN git clone git://github.com/tonistiigi/docker-cli -b update-vendor /go/src/github.com/docker/cli
ARG TARGETPLATFORM
WORKDIR /go/src/github.com/docker/cli
RUN sh ./scripts/build/binary


FROM --platform=$BUILDPLATFORM tonistiigi/xx:golang-riscv AS containerd
RUN git clone git://github.com/tonistiigi/containerd -b update-vendor --depth=1 /go/src/github.com/containerd/containerd
ARG TARGETPLATFORM
WORKDIR /go/src/github.com/containerd/containerd
RUN mkdir out && go build -o /out/ctr ./cmd/ctr && \
  go build -o /out/containerd-shim ./cmd/containerd-shim && \
  go build -o /out/containerd -tags no_btrfs ./cmd/containerd

FROM --platform=$BUILDPLATFORM tonistiigi/xx:golang-riscv AS dockerd
RUN git clone git://github.com/tonistiigi/docker /go/src/github.com/docker/docker && \
  cd /go/src/github.com/docker/docker && \
  git checkout 3de77084d559055e87414c2669b22091a8396990
ARG TARGETPLATFORM
WORKDIR /go/src/github.com/docker/docker
RUN go build -o /out/dockerd -tags "no_quota_support exclude_graphdriver_devicemapper" ./cmd/dockerd/

FROM scratch AS dist
COPY --from=libseccomp /out/ /lib/
COPY --from=crun /src/crun/crun /bin/
COPY --from=runc /out/ /bin/
COPY --from=docker /go/src/github.com/docker/cli/build/docker /bin/docker
COPY --from=containerd /out/ /bin/
COPY --from=dockerd /out/ /bin/

FROM tonistiigi/debian:riscv AS main
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  libyajl2 libcap2 iptables ca-certificates && \
  update-alternatives --set iptables /usr/sbin/iptables-legacy
COPY --from=dist / /usr/
VOLUME /var/lib/docker


FROM main AS crun-demo
RUN apt-get install -y vim
COPY --from=tonistiigi/hello:riscv / /demo/rootfs/
RUN cd /demo/ && crun spec
WORKDIR /demo


FROM main AS dind
ENTRYPOINT ["dockerd"]

FROM main
