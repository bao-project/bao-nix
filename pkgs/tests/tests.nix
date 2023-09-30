# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
    pname = "tests";
    version = "1.0.0";

    src = ../../../src;

    dontBuild = true;
    
    installPhase = ''
        mkdir -p $out
        cp -r $src/* $out
    '';

}

