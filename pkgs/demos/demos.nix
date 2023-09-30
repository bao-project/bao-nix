# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
    pname = "demos";
    version = "1.0.0";

    src = fetchFromGitHub {
        owner = "bao-project";
        repo = "bao-demos";
        rev = "e6f1f6f5556c8e4787516404c3c7eaa5d2feb774"; # branch: master
        sha256 = "sha256-+1cqnfQ80rX5VQa0/UOBZVbyrFL8YSDHebtKRapo7+w=";
    };

    dontBuild = true;
    
    installPhase = ''
        mkdir -p $out
        cp -r $src/* $out
    '';

}


