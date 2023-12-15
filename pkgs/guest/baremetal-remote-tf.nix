# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, toolchain
, python3
, python3Packages
, rsync
, guest_name ? "baremetal"
, platform_cfg
, list_tests
, list_suites
, bao-tests
, tests_srcs
, tests
, testf_patch ? " "
}:

stdenv.mkDerivation rec {
    # Derivation to build the baremetal-guest to run the bao test framework
    # MUT: bao-hypervisor
    pname = guest_name;
    version = "1.0.0";

    platform = platform_cfg.platform_name;
    plat_arch = platform_cfg.platforms-arch.${platform};
    plat_toolchain = platform_cfg.platforms-toolchain.${platform};

     src = fetchFromGitHub {
        owner = "bao-project";
        repo = "bao-baremetal-guest";
        rev = "4010db4ba5f71bae72d4ceaf4efa3219812c6b12"; # branch demo
        sha256 = "sha256-aiKraDtjv+n/cXtdYdNDKlbzOiBxYTDrMT8bdG9B9vU=";
    };
    
    patch = testf_patch;

    nativeBuildInputs = [ toolchain]; #build time dependencies
    buildInputs = [python3 python3Packages.numpy rsync];

    unpackPhase = ''
        mkdir -p $out
        rsync -r $src/ $out
        chmod -R u+w $out
        mkdir -p $out/tests/bao-tests
        cp -r ${bao-tests}/* $out/tests/bao-tests
        cp -r ${tests_srcs}/configs $out/tests/
        cp -r ${tests_srcs}/src $out/tests/
        chmod -R u+w $out/tests/
        mv $out/tests/src/testf_entry.c $out/tests/bao-tests/src/
        cd $out
    '';

    patches = [
         "${patch}"
    ];

    buildPhase = ''
        echo "Platform: ${platform}"
        echo "Suites: ${list_suites}"
        echo "Testes: ${list_tests}"
        export ARCH=${plat_arch}
        export CROSS_COMPILE=${plat_toolchain}
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