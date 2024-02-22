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
, baremetal_srcs_path ? " "
, list_tests ? " "
, list_suites ? " "
, log_level ? "2"
}:

stdenv.mkDerivation rec {
    # Derivation to build the baremetal-guest to run the bao test framework
    # MUT: baremetal-guest
    pname = guest_name;
    version = "1.0.0";

    platform = platform_cfg.platform_name;
    plat_arch = platform_cfg.platforms-arch.${platform};
    plat_toolchain = platform_cfg.platforms-toolchain.${platform};

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

    unpackPhase = ''
        mkdir -p $out/guest_srcs
        rsync -r $guest_srcs/ $out/guest_srcs
    '';

    buildPhase = ''
        export ARCH=${plat_arch}
        export CROSS_COMPILE=${plat_toolchain}-
        make -C $out PLATFORM=${platform}
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp $out/guest_srcs/build/${platform}/baremetal.bin $out/bin/${guest_name}.bin
    '';

}
