# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, toolchain
, openssl
, platform
, bash
}:

stdenv.mkDerivation rec {
    pname = "openSBI";
    version = "bao/demo";

    src = fetchFromGitHub {
        owner = "bao-project";
        repo = "opensbi";
        rev = "4489876e933d8ba0d8bc6c64bae71e295d45faac"; #branch: bao/demos
        sha256 = "sha256-k6f4/lWY/f7qqk0AFY4tdEi4cDilSv/jngaJYhKFlnY=";
    };

    nativeBuildInputs = [ toolchain openssl bash ]; #build time dependencies

    postPatch = ''
        patchShebangs ./scripts
    '';
    
    buildPhase = ''
        export CROSS_COMPILE=riscv64-unknown-elf-
        make PLATFORM=generic \
            FW_PAYLOAD=y \
            FW_PAYLOAD_FDT_ADDR=0x80100000
    '';
    
    installPhase = ''
        mkdir -p $out/build/
        cp -r ./build/platform/generic/firmware/fw_jump.elf $out/build/opensbi.elf
    '';

}
