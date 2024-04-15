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

    platform = setup-cfg.platform_name;
    plat_arch = setup-cfg.arch;
    plat_toolchain = setup-cfg.toolchain_name;

    guest_srcs = if baremetal_srcs_path == " " || baremetal_srcs_path == null then
        fetchFromGitHub {
            owner = "bao-project";
            repo = "bao-baremetal-guest";
            rev = "4010db4ba5f71bae72d4ceaf4efa3219812c6b12"; # branch demo
            sha256 = "sha256-aiKraDtjv+n/cXtdYdNDKlbzOiBxYTDrMT8bdG9B9vU=";
        }
        else
            baremetal_srcs_path;

    nativeBuildInputs = [ toolchain]; #build time dependencies
    buildInputs = [python3 python3Packages.numpy rsync];

    unpackPhase = if tests_path == " " || tests_path == null then
    ''
        mkdir -p $out
        rsync -r $guest_srcs/ $out
    ''
    else
    ''
        mkdir -p $out
        rsync -r $guest_srcs/ $out

        mkdir -p  $out/tests
        rsync -r ${tests_path}/ $out/tests
    '';
    
    buildPhase = if tests_path == " " || tests_path == null then
    ''
        export ARCH=${plat_arch}
        export CROSS_COMPILE=${plat_toolchain}
        make -C $out PLATFORM=${platform}
    ''
    else
    ''
        export ARCH=${plat_arch}
        export CROSS_COMPILE=${plat_toolchain}
        export TESTF_TESTS_DIR=$out/tests/src
        export TESTF_REPO_DIR=$out/tests/bao-tests
        make -C $out PLATFORM=${platform} BAO_TEST=1 SUITES=${list_suites} TESTS=${list_tests} TESTF_LOG_LEVEL=${log_level}
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp $out/build/${platform}/baremetal.bin $out/bin/${guest_name}.bin
    '';

}
