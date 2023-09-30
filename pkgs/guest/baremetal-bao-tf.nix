# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, toolchain
, python3
, python3Packages
, rsync
, platform
, list_tests
, list_suites
, bao-tests
, tests
}:

stdenv.mkDerivation rec {
    # Derivation to build the baremetal-guest to run the bao test framework
    # MUT: bao-hypervisor
    pname = "baremetal-bao-tf";
    version = "1.0.0";

     src = fetchFromGitHub {
        owner = "bao-project";
        repo = "bao-baremetal-guest";
        rev = "4010db4ba5f71bae72d4ceaf4efa3219812c6b12"; # branch demo
        sha256 = "sha256-aiKraDtjv+n/cXtdYdNDKlbzOiBxYTDrMT8bdG9B9vU=";
    };
    
    patch = ../../../baremetal.patch;

    nativeBuildInputs = [ toolchain]; #build time dependencies
    buildInputs = [python3 python3Packages.numpy rsync];

    unpackPhase = ''
        mkdir -p $out
        #copy everything except tests
        rsync -r $src/ $out 
        cp -r ${bao-tests} $out/bao-tests
        cp -r ${tests} $out/tests
        chmod -R u+w $out #make sure we can write to src to apply patches
        cd $out
    '';

    patches = [
         "${patch}"
    ];

    buildPhase = ''
        echo "Platform: ${platform}"
        echo "Suites: ${list_suites}"
        echo "Testes: ${list_tests}"
        export ARCH=aarch64
        export CROSS_COMPILE=aarch64-none-elf-
        export TESTF_TESTS_DIR=$out/tests
        export TESTF_REPO_DIR=$out/bao-tests
        chmod -R u+w bao-tests #make sure we can write to bao-tests
        cd bao-tests
        python3 ./codegen.py -d $TESTF_TESTS_DIR -o $TESTF_REPO_DIR/src/testf_entry.c
        cd ..
        make PLATFORM=${platform} BAO_TEST=1 SUITES=${list_suites} TESTS=${list_tests}
    '';
    
    installPhase = ''
        mkdir -p $out/bin
        cp ./build/${platform}/baremetal.bin $out/bin
    '';
    
}