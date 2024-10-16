# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchgit
, rsync
, setup-cfg
}:

stdenv.mkDerivation rec {
    pname = "linux-image";
    version = "1.0.0";

    linux_image = builtins.path {
        #TODO: change image url. Should come from a release in bao-linux-guest
        path = /home/mafs/bao-demos/images/output/pack.tar.gz;
    };

    buildInputs = [ ];

    unpackPhase = ''
        tar -xvf $linux_image
    '';
    
    installPhase = ''
        mkdir -p $out/image
        cp -r Im* $out/image/LinuxImage    
    '';

}
