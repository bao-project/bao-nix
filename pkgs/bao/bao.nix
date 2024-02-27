# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, fetchurl
, rsync
, toolchain
, bao_srcs_path ? " "
, bao_cfg_repo
, bao_cfg
, setup-cfg
, guests
}:

stdenv.mkDerivation rec {
    # Derivation to build bao to run the bao test framework (as a guest)
    # MUT: bao-hypervisor
    pname = "bao-local";
    version = "1.0.0";

    srcs = if bao_srcs_path == " " || bao_srcs_path == null then
            fetchFromGitHub {
                owner = "bao-project";
                repo = "bao-hypervisor";
                rev = "0575782359132465128491ab2fa44c16e76b57f8"; # branch: demo
                sha256 = "sha256-pCsVpSOuCCQ86HbLbyGpi6nHi5dxa7hbQIuoemE/fSA=";
            }
            else
            bao_srcs_path;

    
    nativeBuildInputs = [ toolchain guests ]; #build time dependencies
    buildInputs = [ rsync ];

    bao_build_cfg = if bao_cfg == " " 
                        then setup-cfg.platform_name 
                        else bao_cfg;

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
        export ARCH=${setup-cfg.arch} 
        export CROSS_COMPILE=${setup-cfg.toolchain_name}-


        # Build Bao
        make PLATFORM=${setup-cfg.platform_name} \
             CONFIG_REPO=$out/configs\
             CONFIG=$bao_build_cfg\
             CPPFLAGS=-DBAO_WRKDIR_IMGS=$out/guests
    '';
    
    installPhase = ''
        mkdir -p $out/bao
        cp -r ./bin/${setup-cfg.platform_name}/${bao_build_cfg}/bao.bin $out/bao
    '';

}

