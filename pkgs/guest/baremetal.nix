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
        rsync -r $guest_srcs/ $out        
    '';
    
    buildPhase = ''
        export ARCH=${setup-cfg.arch}
        export CROSS_COMPILE=${setup-cfg.toolchain_name}-
        if [ "$ARCH" == "aarch64" ]; then
        make -C $out PLATFORM=${setup-cfg.platform_name} \
                ${setup-cfg.irq_flags}
        else
            make -C $out PLATFORM=${setup-cfg.platform_name}
        fi
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp $out/build/${setup-cfg.platform_name}/baremetal.bin $out/bin/${guest_name}.bin
    '';

}
