# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

{ lib
, stdenv
, fetchurl
, ncurses5
, python38
}:

stdenv.mkDerivation rec {
  pname = "aarch64-none-elf";
  version = "11.3.rel1";
  platform = "x86_64";

  src = fetchurl {
    url = "https://developer.arm.com/-/media/Files/downloads/gnu/${version}/binrel/arm-gnu-toolchain-${version}-${platform}-aarch64-none-elf.tar.xz";
    sha256 = "sha256-+55WKpDeGzopYblSGTwcZSCHKqFILApeCreZcOxudpA=";
  };

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';

  # Package -> put the binaries with nix store paths
  preFixup = ''
    find $out -type f | while read f; do
      patchelf "$f" > /dev/null 2>&1 || continue
      patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) "$f" || true
      patchelf --set-rpath ${lib.makeLibraryPath [ "$out" stdenv.cc.cc ncurses5 python38 ]} "$f" || true
    done
  '';

}
