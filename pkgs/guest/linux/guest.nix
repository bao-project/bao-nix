# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, setup-cfg
, toolchain
, fetchFromGitHub
, fetchgit
, dtc
, fakeroot
, rsync
, linuxImage
, initramfs
, dtb

}:

stdenv.mkDerivation rec {

    pname = "linux";
    version = "1.0.0";

    src = fetchFromGitHub {
        owner = "bao-project";
        repo = "bao-static-guest-loader";
        rev = "exp/separate_initramfs"; # The branch to fetch
        sha256 = "sha256-MVsrtgwjnTvrLWqssDFyHNNBJwm1ZMmDg1T2cmWEkUM=";
    };

    nativeBuildInputs = [ toolchain ];
    buildInputs = [ dtc fakeroot ];

    target = "linux";

    buildPhase = ''
        export LINUX_IMAGE=${linuxImage}/image/LinuxImage
        export INITRAMFS=${initramfs}/cpio/rootfs.cpio
        export DTB=${dtb}/dtb/output.dtb
        export TARGET=${target}

        echo "Using Linux Image from: $LINUX_IMAGE"
        echo "Using Initramfs from: $INITRAMFS"
        echo "Using DTB from: $DTB"
        echo "Using Target: $TARGET"

        make \
        IMAGE=$LINUX_IMAGE \
        DTB=$DTB \
        TARGET=$TARGET \
        INITRAMFS=$INITRAMFS \
        ARCH=aarch64
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp linux.bin $out/bin/linux.bin   
    '';

}
