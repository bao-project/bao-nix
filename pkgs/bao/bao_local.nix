# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, fetchurl
, rsync
, toolchain
, bao_srcs_path
, platform_cfg
, guests
}:

stdenv.mkDerivation rec {
    # Derivation to build bao to run the bao test framework (as a guest)
    # MUT: bao-hypervisor
    pname = "bao-local";
    version = "1.0.0";

    platform = platform_cfg.platform_name;
    plat_arch = platform_cfg.platforms-arch.${platform};
    plat_toolchain = platform_cfg.platforms-toolchain.${platform};

    src = bao_srcs_path;
    
    nativeBuildInputs = [ toolchain guests ]; #build time dependencies
    buildInputs = [ rsync ];

    unpackPhase = ''
        mkdir -p $out
        #copy everything except tests
        rsync -r $src/ ./ 
    '';

    buildPhase = ''
        export ARCH=${plat_arch}
        export CROSS_COMPILE=${plat_toolchain}-
        
        # Load guest images
        mkdir -p ./guests
        for guest in ${toString guests}; do
            cp $guest/bin/*.bin ./guests/
        done
        
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


