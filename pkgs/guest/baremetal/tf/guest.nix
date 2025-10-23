# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchgit
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
    version = "1.1.0";

    guest_srcs = if baremetal_srcs_path == " " || baremetal_srcs_path == null then
        fetchgit {
            url = "https://github.com/bao-project/bao-baremetal-test";
            rev = "d32ac417fc7057f1ff510d48a35fb8ec0cde79cd";
            sha256 = "sha256-E9TWtO3jPWttPOf9ZDUistJam6fP8dWQysyYWhIyekQ=";
            fetchSubmodules = true;
        }
        else
            baremetal_srcs_path;


    nativeBuildInputs = [ toolchain]; #build time dependencies
    buildInputs = [python3 python3Packages.numpy rsync];

    unpackPhase = ''
        mkdir -p $out
        mkdir -p $out/tests
        mkdir -p $out/tests/src
        mkdir -p $out/tests/bao-tests

        cp -r ${guest_srcs}/* $out
        rsync -r ${setup-cfg.tests_srcs}/* $out/tests/src
        rsync -r ${setup-cfg.bao-tests}/* $out/tests/bao-tests

        chmod -R +rwx $out
        cd $out/tests/bao-tests/framework
        python3 codegen.py -dir $out/tests/src -o $out/tests/bao-tests/src/testf_entry.c
        cd $out
    '';
    
    buildPhase = ''
        export ARCH=${setup-cfg.arch}
        export CROSS_COMPILE=${setup-cfg.toolchain_name}-
        export TESTF_TESTS_DIR=$out/tests/src
        export TESTF_REPO_DIR=$out/tests/bao-tests
        export BAREMETAL_PARAMS="MEM_BASE=0x10000000"

        if [ "$ARCH" == "aarch64" ]; then
            make -C $out PLATFORM=${setup-cfg.platform_name} $BAREMETAL_PARAMS \
                BAO_TEST=1 SUITES="${list_suites}" TESTS="${list_tests}" \
                TESTF_LOG_LEVEL=${log_level} \
                ${setup-cfg.irq_flags}
        else
            make -C $out PLATFORM=${setup-cfg.platform_name} \
                BAO_TEST=1 SUITES="${list_suites}" TESTS="${list_tests}" \
                TESTF_LOG_LEVEL=${log_level}
        fi
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp $out/build/${setup-cfg.platform_name}/baremetal.bin $out/bin/${guest_name}.bin
    '';

}
