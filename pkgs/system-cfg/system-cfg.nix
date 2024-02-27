# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ 
    pkgs ? import <nixpkgs> {} 
    , platform ? " "
    , bao-tests ? " " #./bao-tests
    , tests_srcs ? " " #./src
    , baremetal_patch ? " " #./baremetal.patch
}:
let
    platforms-arch = {
        zcu102 = "aarch64";
        zcu104 = "aarch64";
        imx8qm = "aarch64";
        tx2 = "aarch64";
        rpi4 = "aarch64";
        qemu-aarch64-virt = "aarch64";
        fvp-a = "aarch64";
        fvp-r = "aarch64";
        fvp-a-aarch32 = "aarch32";
        fvp-r-aarch32 = "aarch32";
        qemu-riscv64-virt = "riscv64";
    };

    platforms-toolchain = {
        qemu-aarch64-virt = "aarch64-none-elf";
        zcu102 = "aarch64-none-elf";
        zcu104 = "aarch64-none-elf";
        imx8qm = "aarch64-none-elf";
        tx2 = "aarch64-none-elf";
        rpi4 = "aarch64-none-elf";
        fvp-a = "aarch64-none-elf";
        fvp-r = "aarch64-none-elf";
        fvp-a-aarch32 = "arm-none-eabi";
        fvp-r-aarch32 = "arm-none-eabi";
        qemu-riscv64-virt = "riscv64-unknown-elf";
    };
in {
    platform_name = "${platform}";
    arch = platforms-arch.${platform};
    toolchain_name = platforms-toolchain.${platform};
    bao-tests = bao-tests;
    tests_srcs = tests_srcs;
    baremetal_patch = baremetal_patch;
}