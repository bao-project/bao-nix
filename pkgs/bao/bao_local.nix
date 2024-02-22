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

    srcs = bao_srcs_path;
    
    nativeBuildInputs = [ toolchain guests ]; #build time dependencies
    buildInputs = [ rsync ];


    unpackPhase = ''
        mkdir -p $out
        mkdir -p $out/srcs
        mkdir -p $out/configs
        mkdir -p $out/guests

        rsync -r $srcs/ $out/srcs
        # cp -r ${srcs}/* $out/srcs
        cp -r ${bao_cfg_repo}/* $out/configs
        for guest in ${toString guests}; do
            cp $guest/bin/*.bin $out/guests/
        done
    '';

    buildPhase = ''
        cd $out/srcs
        export ARCH=${plat_arch}
        export CROSS_COMPILE=${plat_toolchain}


        # Build Bao
        make PLATFORM=${platform}\
             CONFIG_REPO=./config\
             CONFIG=config\
             CPPFLAGS=-DBAO_WRKDIR_IMGS=./guests
    '';
    
    installPhase = ''
        mkdir -p $out/bao
        cp -r ./bin/${platform}/config/bao.bin $out/bao
    '';

}


