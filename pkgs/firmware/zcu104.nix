# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ pkgs
, stdenv
, fetchFromGitHub
, rsync
, toolchain
, platform
, setup-cfg
}:

stdenv.mkDerivation rec {
    pname = "zcu10x";
    version = "2023.1";

    src = fetchFromGitHub {
        owner = "Xilinx";
        repo = "soc-prebuilt-firmware";
        rev = "dc05dc93b8a67b7ff15afe4b01f7d6a91b7bdba7";
        sha256 = "sha256-QRp3HdShxz3SiGRU0UUarEwh+fumkYwDeKS7+1Td5xk=";
    };

    buildInputs = [rsync];
    # dontUnpack = true;
    dontBuild = true;
    dontInstall = true;

    unpackPhase = ''
        mkdir -p $out/firmware/zcu104/
        rsync -r ${src}/${setup-cfg.platform_name}-zynqmp/*.elf $out/firmware/${setup-cfg.platform_name}/
        rsync -r ${src}/${setup-cfg.platform_name}-zynqmp/*.dtb $out/firmware/${setup-cfg.platform_name}/
    '';
}
