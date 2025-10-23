# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
, toolchain
, bison
, flex
, openssl
, setup-cfg
, platform ? "qemu-aarch64-virt"
}:
let
    defconfigMap = {
        qemu-aarch64-virt = "qemu_arm64_defconfig";
        fvp-a = "vexpress_aemv8a_semi_defconfig";
        fvp-a-aarch32 = "vexpress_aemv8a_semi_defconfig";
    };

in
stdenv.mkDerivation rec {
    pname = "u-boot";
    version = "2022.10";

    src = fetchFromGitHub {
        owner = "u-boot";
        repo = "u-boot";
        rev = "v${version}"; 
        sha256 = "sha256-L6AXbJEDx+KoMvqBuJYyIyK2Xn2zyF21NH5mMNvygmM=";
    };

    nativeBuildInputs = [ toolchain bison flex openssl ];


    defconfig = defconfigMap.${platform};
    
    buildPhase = ''
        export CROSS_COMPILE=${setup-cfg.toolchain_name}-
        make ${defconfig}
        echo "CONFIG_TFABOOT=y" >> .config
        echo "CONFIG_SYS_TEXT_BASE=0x60000000" >> .config
        echo "CONFIG_BOOTDELAY=0" >> ./.config 
        echo "CONFIG_BOOTCOMMAND=\"go 0x50000000\"" >> .config
        make
    '';
    
    installPhase = ''
        mkdir -p $out/bin
        cp ./u-boot.bin $out/bin/
    '';

}


