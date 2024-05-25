# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.
{ pkgs
, stdenv
, fetchFromGitHub
, toolchain
, platform
, IRQC ? "QEMU_GICV3"
}:
let
  u-boot = pkgs.callPackage ./u-boot/u-boot.nix 
  {
    inherit toolchain;
  };

  atf = pkgs.callPackage ./atf/atf.nix {
    inherit toolchain;
    inherit u-boot; 
    inherit platform;
    gic-version = IRQC;
  };
in
stdenv.mkDerivation rec {
    pname = "qemu_aarch64_virt";
    version = "firmware";

    dontUnpack = true;
    dontBuild = true;
    
    nativeBuildInputs = [
        u-boot
        atf
    ];

    installPhase = ''
        mkdir -p $out
        touch $out/test_derivation.txt
        find ${atf} -type f -exec cp {} $out \;
        find ${u-boot} -type f -exec cp {} $out \;
    '';
}