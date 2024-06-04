# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.
{ pkgs
, stdenv
, fetchFromGitHub
, toolchain
, platform
, setup-cfg
}:
let
  sbi = pkgs.callPackage ./openSBI/openSBI.nix {
    inherit toolchain;
    inherit platform;
  };
in
stdenv.mkDerivation rec {
    pname = "qemu_riscv64_virt";
    version = "firmware";

    dontUnpack = true;
    dontBuild = true;
    
    nativeBuildInputs = [
        sbi
    ];

    installPhase = ''
        mkdir -p $out
        touch $out/test_derivation.txt
        find ${sbi} -type f -exec cp {} $out \;
    '';
}