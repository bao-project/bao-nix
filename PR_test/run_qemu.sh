#!/usr/bin/env nix-shell
#!nix-shell --pure -p qemu -i bash

qemu-system-aarch64 -nographic\
   -M virt,secure=on,virtualization=on,gic-version=3 \
   -cpu cortex-a53 -smp 4 -m 4G\
   -bios ./result-2/bin/qemu-aarch64-virt/flash.bin \
   -device loader,file="./result-3/bin/bao.bin",addr=0x50000000,force-raw=on\
   -device virtio-net-device,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:5555-:22\
   -device virtio-serial-device -chardev pty,id=serial3 -device virtconsole,chardev=serial3