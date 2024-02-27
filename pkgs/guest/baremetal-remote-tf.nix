# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, system-cfg
, toolchain
, python3
, python3Packages
, rsync
, guest_name ? "baremetal"
, list_tests
, list_suites
, log_level ? "2"
}:

stdenv.mkDerivation rec {
    # Derivation to build the baremetal-guest to run the bao test framework
    # MUT: bao-hypervisor
    pname = guest_name;
    version = "1.0.0";

     src = fetchFromGitHub {
        owner = "bao-project";
        repo = "bao-baremetal-guest";
        rev = "4010db4ba5f71bae72d4ceaf4efa3219812c6b12"; # branch demo
        sha256 = "sha256-aiKraDtjv+n/cXtdYdNDKlbzOiBxYTDrMT8bdG9B9vU=";
    };

    nativeBuildInputs = [ toolchain]; #build time dependencies
    buildInputs = [python3 python3Packages.numpy rsync];

    unpackPhase = ''
        mkdir -p $out
        rsync -r $src/ $out
        chmod -R u+w $out
        mkdir -p $out/tests/bao-tests
        mkdir -p $out/tests/src
        cp -r ${system-cfg.bao-tests}/* $out/tests/bao-tests
        cp -r ${system-cfg.tests_srcs}/* $out/tests/src
        chmod -R u+w $out/tests/
        cd $out
    '';

    patches = [
         "${system-cfg.baremetal_patch}"
    ];

    buildPhase = ''
        export ARCH=${system-cfg.arch}
        export CROSS_COMPILE=${system-cfg.toolchain_name}-
        export TESTF_TESTS_DIR=$out/tests/src
        export TESTF_REPO_DIR=$out/tests/bao-tests
        chmod -R u+w $out/tests/bao-tests
        make -C $out PLATFORM=${system-cfg.platform_name} \
            BAO_TEST=1 SUITES=${list_suites} TESTS=${list_tests} \
            TESTF_LOG_LEVEL=${log_level}
    '';
    
    installPhase = ''
        mkdir -p $out/bin
        cp ./build/${system-cfg.platform_name}/baremetal.bin $out/bin/${guest_name}.bin
    '';
    
}