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
, log_level ? "2"
, bao-tests
, tests_srcs
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
        mkdir -p $out/tests/src
        cp -r ${bao-tests}/* $out/tests/bao-tests
        cp -r ${tests_srcs}/* $out/tests/src
        chmod -R u+w $out/tests/
        cd $out
    '';

    patches = [
         "${patch}"
    ];

    buildPhase = ''
        export ARCH=${plat_arch}
        export CROSS_COMPILE=${plat_toolchain}-
        export TESTF_TESTS_DIR=$out/tests/src
        export TESTF_REPO_DIR=$out/tests/bao-tests
        chmod -R u+w $out/tests/bao-tests
        make -C $out PLATFORM=${platform} BAO_TEST=1 SUITES=${list_suites} TESTS=${list_tests} TESTF_LOG_LEVEL=${log_level}
    '';
    
    installPhase = ''
        mkdir -p $out/bin
        cp ./build/${platform}/baremetal.bin $out/bin/${guest_name}.bin
    '';
    
}