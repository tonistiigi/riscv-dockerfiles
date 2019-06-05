#!/usr/bin/env sh

set -e

mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

if [ "$1" == "uninstall" ]; then
  if [ -f /proc/sys/fs/binfmt_misc/qemu-riscv64 ]; then
    echo -1 > /proc/sys/fs/binfmt_misc/qemu-riscv64
  fi
  exit 0
fi

echo ':qemu-riscv64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-riscv64:OCFP' > /proc/sys/fs/binfmt_misc/register