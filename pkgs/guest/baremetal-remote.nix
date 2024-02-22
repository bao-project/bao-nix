# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, toolchain
, guest_name ? "baremetal"
, platform_cfg
}:

stdenv.mkDerivation rec {
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

    nativeBuildInputs = [ toolchain]; #build time dependencies

    buildPhase = ''
        export ARCH=${plat_arch}
        export CROSS_COMPILE=${plat_toolchain}-
        make PLATFORM=${platform}
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp ./build/${platform}/baremetal.bin $out/bin/${guest_name}.bin
    '';

}
