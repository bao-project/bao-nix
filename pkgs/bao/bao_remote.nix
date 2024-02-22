# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, fetchurl
, rsync
, toolchain
, bao_cfg_repo
, bao_cfg
, platform_cfg
, guests
}:

stdenv.mkDerivation rec {
    pname = "bao-remote";
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
    
    nativeBuildInputs = [ toolchain guests ]; #build time dependencies
    buildInputs = [ rsync ];

    bao_build_cfg = if bao_cfg == " " then platform else bao_cfg;

    unpackPhase = ''
        mkdir -p $out
        mkdir -p $out/srcs
        mkdir -p $out/configs
        mkdir -p $out/guests

        rsync -r $srcs/ $out/srcs
        cp -r ${bao_cfg_repo}/* $out/configs
        for guest in ${toString guests}; do
            cp $guest/bin/*.bin $out/guests/
        done
    '';
    
    buildPhase = ''
        cd $out/srcs
        export ARCH=${plat_arch}
        export CROSS_COMPILE=${plat_toolchain}-


        # Build Bao
        make PLATFORM=${platform}\
             CONFIG_REPO=$out/configs\
             CONFIG=$bao_build_cfg\
             CPPFLAGS=-DBAO_WRKDIR_IMGS=$out/guests
    '';
    
    installPhase = ''
        mkdir -p $out/bao
        cp -r ./bin/${platform}/${bao_build_cfg}/bao.bin $out/bao
    '';

}


