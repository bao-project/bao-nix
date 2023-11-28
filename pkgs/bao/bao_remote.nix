# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, fetchurl
, toolchain
, bao_cfg
, platform_cfg
}:

stdenv.mkDerivation rec {
    pname = "bao";
    version = "1.0.0";

    platform = platform_cfg.platform_name;
    plat_arch = platform_cfg.platforms-arch.${platform};
    plat_toolchain = platform_cfg.platforms-toolchain.${platform};

    srcs = fetchFromGitHub {
        owner = "bao-project";
        repo = "bao-hypervisor";
        rev = "0575782359132465128491ab2fa44c16e76b57f8"; # branch: demo
        sha256 = "sha256-pCsVpSOuCCQ86HbLbyGpi6nHi5dxa7hbQIuoemE/fSA=";
    };
    
    nativeBuildInputs = [ toolchain ]; #build time dependencies

    buildPhase = ''
        export ARCH=${plat_arch}
        export CROSS_COMPILE=${plat_toolchain}-
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


