# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, fetchurl
, toolchain
, guest
, demos
, platform
}:

stdenv.mkDerivation rec {
    pname = "bao";
    version = "1.0.0";

    srcs = fetchFromGitHub {
        owner = "bao-project";
        repo = "bao-hypervisor";
        rev = "0575782359132465128491ab2fa44c16e76b57f8"; # branch: demo
        sha256 = "sha256-pCsVpSOuCCQ86HbLbyGpi6nHi5dxa7hbQIuoemE/fSA=";
    };
    
    nativeBuildInputs = [ toolchain guest demos]; #build time dependencies

    buildPhase = ''
        export ARCH=aarch64
        export CROSS_COMPILE=aarch64-none-elf-
        export DEMO=baremetal
        mkdir -p ./config
        cp -L ${demos}/demos/$DEMO/configs/${platform}.c \
                ./config/$DEMO.c
        mkdir -p ./$DEMO
        cp -L ${guest}/bin/baremetal.bin ./$DEMO
        make PLATFORM=${platform}\
             CONFIG_REPO=./config\
             CONFIG=$DEMO\
             CPPFLAGS=-DBAO_DEMOS_WRKDIR_IMGS=./$DEMO
    '';
    
    installPhase = ''
        mkdir -p $out/bin
        cp ./bin/${platform}/$DEMO/bao.bin $out/bin
    '';

}


