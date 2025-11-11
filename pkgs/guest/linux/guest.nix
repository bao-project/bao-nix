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
, python3
, python3Packages
, linuxImage
, initramfs
, dtb
}:

let

  # Define the fdt Python package
  fdt = python3Packages.buildPythonPackage rec {
    pname = "fdt";
    version = "0.3.3"; # Replace with the appropriate version

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1li6vxgjvzvfrc3zwabiy0a3xdav21sg9i0k964vhapg1y9ib8l1"; # Replace with the correct hash
    };
  };
in
stdenv.mkDerivation rec {
    pname = "linux";
    version = "1.0.0";

    src = fetchFromGitHub {
        owner = "bao-project";
        repo = "bao-static-guest-loader";
        rev = "exp/separate_initramfs"; # The branch to fetch
        sha256 = "sha256-qkQzF8KNdp9Gju3QZzSim4k7xFpcSN8aAVBtD4umlsg=";
    };

    nativeBuildInputs = [ toolchain python3 fdt ];
    buildInputs = [ dtc fakeroot ];

    target = "linux";

    arch = if setup-cfg.arch == "riscv64" then "riscv" else setup-cfg.arch;

    buildPhase = ''
        export LINUX_IMAGE=${linuxImage}/image/LinuxImage
        export INITRAMFS=${initramfs}/cpio/rootfs.cpio
        export DTB=${dtb}/dtb/output.dtb
        export TARGET=${target}

        make \
        IMAGE=$LINUX_IMAGE \
        DTB=$DTB \
        TARGET=$TARGET \
        INITRAMFS=$INITRAMFS \
        ARCH=${arch}
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp linux.bin $out/bin/linux.bin   
    '';
}
