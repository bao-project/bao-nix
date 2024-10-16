# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchgit
, dtc
, dtsPath
, setup-cfg
}:

stdenv.mkDerivation rec {

    pname = "dtb";
    version = "1.0.0";

    output-name = "output";

    src = dtsPath;

    buildInputs = [ dtc ];

    dontUnpack = true;
    
    buildPhase = ''
        echo "Compiling dts..."
        dtc -I dts -O dtb -o ${output-name}.dtb $src
    '';

    installPhase = ''
        mkdir -p $out/dtb
        cp ${output-name}.dtb $out/dtb/    
    '';

}
