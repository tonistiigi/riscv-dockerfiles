
# build:
# docker build -t tonistiigi/binfmt:riscv .

# run:
# docker run --privileged --rm tonistiigi/binfmt:riscv
# docker run --privileged --rm tonistiigi/binfmt:riscv uninstall

FROM debian:buster AS build
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential git python pkgconf libglib2.0-dev libpixman-1-dev ca-certificates file
WORKDIR /src
RUN git clone git://github.com/tiborvass/qemu && \
  cd qemu && \
  git checkout a3b4db245017e37662a919e42622aaca9c375949
WORKDIR /src/qemu
RUN ./configure --static --disable-system --target-list=riscv64-linux-user && \
  make && \
  file ./riscv64-linux-user/qemu-riscv64 | grep "statically linked"

FROM alpine
COPY install.sh /
COPY --from=build /src/qemu/riscv64-linux-user/qemu-riscv64 /usr/bin/qemu-riscv64
ENTRYPOINT ["/install.sh"]