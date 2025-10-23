# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.
{ pkgs
, stdenv
, fetchFromGitHub
, toolchain
, platform
, setup-cfg
}:

stdenv.mkDerivation rec {
  pname = "fvp-r";
  version = "firmware";

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [
    # No build inputs because no u-boot or atf needed
  ];

  installPhase = ''
    # No additional files to copy
    mkdir -p $out
    touch $out/weak_output.txt
  '';
}