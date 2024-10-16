# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchgit
, toolchain
, python3
, python3Packages
, rsync
, setup-cfg
, guest_name ? "test"
, src_path ? " "
, tests_path ? " "
, list_tests ? " "
, list_suites ? " "
, log_level ? "2"
}:

stdenv.mkDerivation rec {
    # Derivation to build a linux application to run the bao test framework
    # MUT: linux-guest
    pname = guest_name;
    version = "1.0.0";

    guest_srcs = src_path;

    nativeBuildInputs = [toolchain]; #build time dependencies
    buildInputs = [python3 python3Packages.numpy rsync];

    unpackPhase = ''
        mkdir -p $out
        mkdir -p $out/tests
        mkdir -p $out/tests/src
        mkdir -p $out/tests/bao-tests

        rsync -r ${guest_srcs}/ $out
        rsync -r ${setup-cfg.tests_srcs}/* $out/tests/src
        rsync -r ${setup-cfg.bao-tests}/* $out/tests/bao-tests

        chmod -R +rwx $out
        cd $out/tests/bao-tests/framework
        python3 codegen.py -dir $out/tests/src -o $out/tests/bao-tests/src/testf_entry.c
        cd $out
    '';
    
    buildPhase = ''
        export ARCH=${setup-cfg.arch}
        export CROSS_COMPILE=aarch64-none-linux-gnu
        export TESTF_TESTS_DIR=$out/tests/src
        export TESTF_REPO_DIR=$out/tests/bao-tests

        make BAO_TEST=1 SUITES="${list_suites}" TESTS="${list_tests}" \
                TESTF_LOG_LEVEL=${log_level} \
                ${setup-cfg.irq_flags} 
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp $out/program.out $out/bin/program.out   
    '';
}
