# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchurl
, rsync
, setup-cfg
}:

stdenv.mkDerivation rec {
    pname = "linux-image";
    version = "1.0.0";

    linux_image = fetchurl {
        url = "https://github.com/bao-project/bao-linux-test/releases/download/v1.0.0-${setup-cfg.platform_name}/Image-${setup-cfg.platform_name}.tar.gz";
        sha256 = "sha256-m8fY1Rujy8f8z0Bb4kyK6bk5ItZRDCFxWXf4wEeqD3g=";
    };

    buildInputs = [ ];

    unpackPhase = ''
        tar -xvf $linux_image
    '';
    
    installPhase = ''
        mkdir -p $out/image
        cp -r wrkdir/Im* $out/image/LinuxImage    
    '';

}
