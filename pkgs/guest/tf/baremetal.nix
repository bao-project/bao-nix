# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, toolchain
, python3
, python3Packages
, rsync
, setup-cfg
, guest_name ? "baremetal"
, baremetal_srcs_path ? " "
, tests_path ? " "
, list_tests ? " "
, list_suites ? " "
, log_level ? "2"
}:

stdenv.mkDerivation rec {
    # Derivation to build the baremetal-guest to run the bao test framework
    # MUT: baremetal-guest
    pname = guest_name;
    version = "1.0.0";

    guest_srcs = if baremetal_srcs_path == " " || baremetal_srcs_path == null then
        fetchFromGitHub {
            owner = "bao-project";
            repo = "bao-baremetal-guest";
            rev = "c7973b4cbbfee1baecd6e0705261d5c4a01d3318";
            sha256 = "sha256-uXJi9ow87P798JrztsB0BeAhqEW5Fnsx2uHfrUvPCwk=";
        }
        else
            baremetal_srcs_path;


    nativeBuildInputs = [ toolchain]; #build time dependencies
    buildInputs = [python3 python3Packages.numpy rsync];

    unpackPhase = ''
        mkdir -p $out
        mkdir -p  $out/tests
        mkdir -p $out/tests/src
        mkdir -p $out/tests/bao-tests


        rsync -r $guest_srcs/ $out
        rsync -r ${setup-cfg.tests_srcs}/* $out/tests/src
        rsync -r ${setup-cfg.bao-tests}/* $out/tests/bao-tests

        chmod -R +rwx $out
        cd $out/tests/bao-tests/framework
        python3 codegen.py -dir $out/tests/src -o $out/tests/bao-tests/src/testf_entry.c
        cd $out
    '';

    patches = [
        "${setup-cfg.baremetal_patch}"
    ];
    
    buildPhase = ''
        export ARCH=${setup-cfg.arch}
        export CROSS_COMPILE=${setup-cfg.toolchain_name}-
        export TESTF_TESTS_DIR=$out/tests/src
        export TESTF_REPO_DIR=$out/tests/bao-tests
        make -C $out PLATFORM=${setup-cfg.platform_name} BAO_TEST=1 SUITES=${list_suites} TESTS=${list_tests} TESTF_LOG_LEVEL=${log_level}
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp $out/build/${setup-cfg.platform_name}/baremetal.bin $out/bin/${guest_name}.bin
    '';

}
