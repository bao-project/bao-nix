# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, toolchain
, platform
}:

stdenv.mkDerivation rec {
    pname = "baremetal-guest";
    version = "1.0.0";

    src = fetchFromGitHub {
        owner = "bao-project";
        repo = "bao-baremetal-guest";
        rev = "4010db4ba5f71bae72d4ceaf4efa3219812c6b12"; # branch demo
        sha256 = "sha256-aiKraDtjv+n/cXtdYdNDKlbzOiBxYTDrMT8bdG9B9vU=";
    };

    nativeBuildInputs = [ toolchain]; #build time dependencies

    buildPhase = ''
        export ARCH=aarch64
        export CROSS_COMPILE=aarch64-none-elf-
        make PLATFORM=${platform}
    '';
    
    installPhase = ''
        mkdir -p $out/bin
        cp ./build/${platform}/baremetal.bin $out/bin
    '';

}


