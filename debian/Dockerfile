
# docker build --platform=linux/riscv64 -t tonistiigi/debian:riscv .

FROM --platform=$BUILDPLATFORM debian:sid AS debootstrap
RUN apt-get update && apt-get install -y --no-install-recommends \
  debootstrap

RUN echo "deb http://ftp.ports.debian.org/debian-ports sid main" >> /etc/apt/sources.list && \
apt-get install -y debian-ports-archive-keyring && \
dpkg --add-architecture riscv64 && \
apt-get update

RUN debootstrap \
  --keyring=/usr/share/keyrings/debian-ports-archive-keyring.gpg \
  --arch=riscv64 \
  --variant=minbase \
  --include=debian-ports-archive-keyring \
  sid /rootfs http://ftp.ports.debian.org/debian-ports && \
  
  rm -rf /rootfs/var/log/dpkg.log && \
	rm -rf /rootfs/var/log/bootstrap.log && \
	rm -rf /rootfs/var/log/alternatives.log && \
	rm -rf /rootfs/var/cache/ldconfig/aux-cache && \
	rm -rf /rootfs/var/cache/apt/* && \
  rm -rf /rootfs/var/lib/apt/lists/*

FROM scratch
COPY --from=debootstrap /rootfs/ /
CMD ["bash"]