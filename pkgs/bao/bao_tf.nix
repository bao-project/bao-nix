# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, fetchurl
, toolchain
, python3
, python3Packages
, rsync
, guest
, demos
, platform
}:

stdenv.mkDerivation rec {
    # Derivation to build bao to run the bao test framework (as a guest)
    # MUT: bao-hypervisor
    pname = "bao-tf";
    version = "1.0.0";

    src = ../../../../.;
    
    nativeBuildInputs = [ toolchain guest demos]; #build time dependencies
    buildInputs = [python3 python3Packages.numpy rsync];

    unpackPhase = ''
        mkdir -p $out
        #copy everything except tests
        rsync -r --exclude 'tests' $src/ $out 
        cd $out
    '';

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


